(import [threading [Lock Event Thread]]
    [playback.gstplayer [GstPlayer]]
    [playback.playlist [Playlist]])
(require [hy.contrib.walk [let]])

(defclass Player []
  (defn --init-- [self]
    (setv self.backend (GstPlayer))
    (setv self.backend-lock (Lock))
    (setv self.playlist (Playlist))
    (setv self.play-event (Semaphore 0))

    (.run self.backend)
    (setv self.thread (Thread :target self.playback
                              :daemon True))
    (.start self.thread))

  (defn play [self]
    (.set self.play-event))

  (defn pause [self]
    (.clear self.play-event)
    (with (self.backend-lock)
      (.pause self.backend)))

  (defn playback [self]
    (while True
      (.wait self.play-event)
      (let [path (.next-song self.playlist)]
        (if (is None path)
          (.wait self.play-event))
        (with (self.backend-lock)
          (.play-file self.backend path)))
      (.block self.backend)))

  (defn --enter-- [self]
    (.acquire self.backend-lock)
    self.backend)

  (defn --exit-- [self type value traceback]
    (.release self.backend-lock)))
