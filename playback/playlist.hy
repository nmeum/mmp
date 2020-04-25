(import [threading [Lock Semaphore Thread]]
        [random [randrange]])
(require [hy.contrib.walk [let]])

(defclass Playlist []
  (defn --init-- [self]
    (setv self.cur-index None)
    (setv self.mode {
      :repeat False :random False
      :single False :consume False
    })
    (setv self.mode-lock (Lock))
    (setv self.list [])
    (setv self.list-lock (Lock)))

  (defn psize [self]
    (with (self.list-lock)
      (len self.list)))

  (defn set-mode [self &optional [repeat None] [random None]
                                 [single None] [consume None]]
    (let [h { :repeat repeat :random random
              :single single :consume consume }]
      (setv self.mode
        (with (self.mode-lock)
          (dict (map
                  (fn [pair]
                    (, (first pair)
                       (if (is None (last pair))
                         (get self.mode (first pair))
                         (last pair))))
                  (.items h)))))))

  (defn get-mode [self]
    (with (self.mode-lock)
      self.mode))

  (defn add-song [self path]
    (with (self.list-lock)
      (.append self.list path)))

  (defn del-song [self path]
    (with (self.list-lock)
      (.remove self.list path)))

  (defn next-song [self]
    (defn next-index [mode]
      ;; TODO: Handle repeat mode
      (if (not self.list)
        None
        (if (is None self.cur-index)
          0
          (let [n (if (get mode :random)
                      (randrange (len self.list))
                      (inc self.cur-index))]
            (if (>= n (len self.list))
              (if (get mode :repeat) 0 None)
              n)))))

    (let [m (with (self.mode-lock) self.mode)]
      (with (self.list-lock)
        (if (get m :consume)
          (.pop self.cur-index))
        (let [idx (next-index m)]
          (setv self.cur-index idx)
          (if (is None idx)
            None
            (get self.list idx)))))))
