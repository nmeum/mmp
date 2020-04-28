(import mpd
  [playback.playlist [Song]])
(require [hy.contrib.walk [let]])

(defclass Commands [object]
  (defn --init-- [self]
    (setv self.handlers {}))

  (defn _serialize-dict [self dict]
    (defn _serialize-values [dict]
      (dfor (, key value) (.items dict)
        [key (if (isinstance value bool)
               (if value 1 0)
               value)]))

    (.rstrip (reduce (fn [rest pair]
                       (+ rest
                          (.format "{}: {}" (first pair) (last pair))
                          mpd.DELIMITER))
                      (.items (_serialize-values dict)) "") mpd.DELIMITER))

  (defn _serialize-song [self song]
    (._serialize-dict self
      {#**
        {
          "file" (. song path)
          "Pos"  (. song position)
        }
       #**
        (. song metadata)
      }))

  (defn serialize [self value]
    (cond
      [(isinstance value dict)
        (._serialize-dict self value)]
      [(isinstance value Song)
        (._serialize-song self value)]
      [True value]))

  (defn add [self name]
    (fn [func]
      (if (in name self.handlers)
        (raise (ValueError (% "%s already registered" name)))
        (do
          (assoc self.handlers name func)
          func))))

  (defn handle [self playback beets cmd]
    (if (in cmd.name self.handlers)
      (let [handler (get self.handlers cmd.name)
            resp    (handler playback beets cmd.args)]
        (.serialize self resp))
      (raise (NotImplementedError (% "%s has not ben implemented" cmd.name))))))

(setv commands (Commands))
