(import [threading [Lock Semaphore Thread]]
    [queue [Queue]]
    [playback.player [*]])
(require [hy.contrib.walk [let]])

(defclass SongQueue []
  (defn --init-- [self]
    (setv self.player (GstPlayer))
    (setv self.player-lock (Lock))
    (setv self.queue (Queue))

    (.run self.player)
    (setv self.thread (Thread :target self.play
                              :daemon True))
    (.start self.thread))

  (defn add-file [self file]
    (.put self.queue file))

  (defn play [self]
    (while True
      (let [path (.get self.queue)]
        (with (self.player-lock)
          (.play-file self.player path)))
        (.block self.player)))

  (defn --enter-- [self]
    (.acquire self.player-lock)
    self.player)

  (defn --exit-- [self type value traceback]
    (.release self.player-lock)))
