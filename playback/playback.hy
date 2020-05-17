(import [threading [*]]
    [playback.gstplayer [GstPlayer]]
    [playback.playlist [Playlist]])
(require [hy.contrib.walk [let]])

(defclass Playback []
  (defn __init__ [self]
    (setv self._player (GstPlayer))
    (setv self._player-lock (RLock))
    (setv self._playlist (Playlist))
    (setv self._playlist-lock (RLock))

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
    (let [play-next (fn []
                      (with (playlist self)
                        (let [song (.next playlist)]
                         (if (is None song)
                           False
                           (do
                             (.play-file self._player (. song path))
                             True)))))]
      (with (playlist self)
        (when (not (is None index))
          (.stop self)
          (.nextup playlist index))
        (.set_callback self._player play-next)
        (with (self._player-lock)
          (if (is None (.current playlist))
            (play-next)
            (.play self._player))))))

  (defn pause [self]
    (.clear_callback self._player)
    (with (self._player-lock)
      (.pause self._player)))

  (defn stop [self]
    (.clear_callback self._player)
    (with (playlist self)
      (.reset playlist))
    (with (self._player-lock)
      (.stop self._player)))

  (defn next [self]
    (with (playlist self)
      (let [song (.next playlist)]
        (if (is None song)
          (.stop self)
          (.play-file self._player (. song path)))
        song)))

  ;; TODO: Implement prev

  (defn remove [self range]
    (with (playlist self)
      (let [song (.current playlist)]
        (if (and (not (is None song))
                 (in (. song position) range))
            (let [s (.next self)]
              (if (or (is None s)
                      (= (. s position) (. song position)))
                (.stop self)))))
      (.remove playlist range)))

  (defn __enter__ [self]
    """Context manager for aquiring access to the underlying playlist.
       All code executed in the context manager will be executed atomic
       on the playlist object, i.e. the song won't be changed in between."""
    (.acquire self._playlist-lock)
    self._playlist)

  (defn __exit__ [self type value traceback]
    (.release self._playlist-lock)))
