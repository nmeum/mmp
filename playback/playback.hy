(import [threading [*]]
    [playback.gstplayer [GstPlayer]]
    [playback.playlist [Playlist]])
(require [hy.contrib.walk [let]])

(defclass Playback []
  (defn __init__ [self]
    (setv self._player (GstPlayer))
    (setv self._player-lock (RLock))
    (setv self._playlist (Playlist))
    (setv self._playlist-lock (Lock))

    (.run self._player))

  (defn state [self]
    (let [state (with (self._player-lock)
                      (.state self._player))]
      (cond
        [(= state "play") "play"]
        [(= state "pause") "pause"]
        [True "stop"])))

  ;; TODO: Make methods block until state actually changed

  (defn play [self &optional index]
    (let [cb (fn []
               (with (playlist self)
                 (.play-file self._player (. (.next playlist) path))))]
      (with (playlist self)
        (when (not (is None index))
          (.stop self)
          (.nextup playlist index))
        (.set_callback self._player cb)
        (with (self._player-lock)
          (if (is None (.current playlist))
            (.play-file self._player (. (.next playlist) path))
            (.play self._player))))))

  (defn pause [self]
    (.clear_callback self._player)
    (with (self._player-lock)
      (.pause self._player)))

  (defn stop [self]
    (.clear_callback self._player)
    (with (self._player-lock)
      (.stop self._player)))

  (defn __enter__ [self]
    """Context manager for aquiring access to the underlying playlist.
       All code executed in the context manager will be executed atomic
       on the playlist object, i.e. the song won't be changed in between."""
    (.acquire self._playlist-lock)
    self._playlist)

  (defn __exit__ [self type value traceback]
    (.release self._playlist-lock)))
