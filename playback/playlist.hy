(import [random [randrange]] os)
(require [hy.contrib.walk [let]])

(defclass Song []
  (setv path None)
  (setv metadata {})
  (setv position 0)

  (defn __init__ [self path metadata]
    (if (not (os.path.isfile path))
      (raise (FileNotFoundError
               (.format "file '{}' does not exist" path))))

    (setv self.path path)
    (setv self.metadata metadata)))

(defclass Playlist []
  (setv mode {
      :repeat False :random False
      :single False :consume False
  })

  (defn __init__ [self]
    (setv self._current None)
    (setv self._next None)
    (setv self._list []))

  (defn __iter__ [self]
    (iter self._list))

  (defn _get-song [self index]
    (let [song (get self._list index)]
      (setv song.position index)
      song))

  (defn psize [self]
    (len self._list))

  (defn current [self]
    (if (is None self._current)
      None
      (get self._list self._current)))

  (defn add [self song]
    (if (isinstance song Song)
      (.append self._list song)
      (raise (TypeError "not an instance of Song"))))

  (defn get [self index]
    (._get-song self index))

  (defn remove [self range]
    (let [start (. range start) stop (. range stop)]
      (if (= start stop)
        (.pop self._list start)
        (setv self._list (cut self._list start stop)))))

  (defn reset [self]
    (setv self._current None)
    (setv self._next None))

  (defn nextup [self index]
    (if (>= index (len self._list))
      (raise (IndexError "song position out of range"))
      (setv self._next index)))

  (defn next [self]
    (defn next-index [mode]
      ;; TODO: Handle repeat mode
      ;; XXX: Maybe use threading macro (->)
      (if (not self._list)
        None
        (if (is None self._current)
          0
          (let [n (if (get mode :random)
                      (randrange (len self._list))
                      (inc self._current))]
            (if (>= n (len self._list))
              (if (get mode :repeat) 0 None)
              n)))))

    (if (get self.mode :consume)
      (.pop self._current))
    (let [idx (if (is None self._next)
                  (next-index self.mode)
                  (. self _next))]
      (setv self._next None)
      (setv self._current idx)
      (if (is None idx)
        None
        (._get-song self idx)))))
