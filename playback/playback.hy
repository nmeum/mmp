(import [threading [*]]
    [playback.gstplayer [GstPlayer]]
    [playback.playlist [Playlist]])
(require [hy.contrib.walk [let]])

(defclass Playback []
  (defn --init-- [self]
    (setv self._player (GstPlayer))
    (setv self._player-lock (RLock))
    (setv self._playlist (Playlist))
    (setv self._playlist-lock (Lock))

    (setv self._play-start (BoundedSemaphore 1))
    (.acquire self._play-start)

    (.run self._player)
    (setv self._thread (Thread :target self._playback
                              :daemon True))
    (.start self._thread))

  (defn _playback [self]
    (while True
      (.acquire self._play-start)
      (if (= (.state self) "pause")
        (with (self._player-lock)
          (.play self._player))
        (let [song (with (p self) (.next p))]
          (if (is None song)
            (.acquire self._play-start))
          (with (self._player-lock)
            (.play-file self._player (. song path)))))
      (.block self._player)))

  (defn state [self]
    (let [state (with (self._player-lock)
                      (.state self._player))]
      (cond
        [(= state "play") "play"]
        [(= state "pause") "pause"]
        [True "stop"])))

  ;; TODO: Make methods block until state actually changed?
  ;; In general: How should intertwined state changes be handled?

  (defn play [self &optional index]
    (if (not (is None index))
      (let [song (with (p self) (.get p index))]
        (with (self._player-lock)
          (.stop self)
          (.set-file self._player (. song path)))))
    (try
      (.release self._play-start)
      (except [ValueError])))

  (defn pause [self]
    (with (self._player-lock)
      (.pause self._player)))

  (defn stop [self]
    (with (self._player-lock)
      (.stop self._player)))

  (defn --enter-- [self]
    """Context manager for aquiring access to the underlying playlist.
       All code executed in the context manager will be executed atomic
       on the playlist object, i.e. the song won't be changed in between."""
    (.acquire self._playlist-lock)
    self._playlist)

  (defn --exit-- [self type value traceback]
    (.release self._playlist-lock)))
