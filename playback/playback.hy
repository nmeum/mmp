(import [threading [Lock Event Thread]]
    [playback.gstplayer [GstPlayer]]
    [playback.playlist [Playlist]])
(require [hy.contrib.walk [let]])

(defclass Playback []
  (defn --init-- [self]
    (setv self.player (GstPlayer))
    (setv self.player-lock (Lock))
    (setv self.playlist (Playlist))
    (setv self.play-event (Semaphore 0))

    (.run self.player)
    (setv self.thread (Thread :target self.playback
                              :daemon True))
    (.start self.thread))

  (defn play [self]
    (.set self.play-event))

  (defn pause [self]
    (.clear self.play-event)
    (with (self.player-lock)
      (.pause self.player)))

  (defn playback [self]
    (while True
      (.wait self.play-event)
      (let [path (.next-song self.playlist)]
        (if (is None path)
          (.wait self.play-event))
        (with (self.player-lock)
          (.play-file self.player path)))
      (.block self.player)))

  (defn --enter-- [self]
    (.acquire self.player-lock)
    self.player)

  (defn --exit-- [self type value traceback]
    (.release self.player-lock)))
