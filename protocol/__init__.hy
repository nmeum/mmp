(import mpd
  [playback.playlist [Song]])
(require [hy.contrib.walk [let]])

(defclass Commands [object]
  (defn --init-- [self]
    (setv self.handlers {}))

  (defn convert-dict [self dict]
    (dfor (, key value) (.items dict)
      [key (if (isinstance value bool)
             (if value 1 0)
             value)]))

  (defn convert-song [self song]
    (self.dict->mpdstr
      {#**
        (. song metadata)
       #**
        {
          "file" (. song path)
          "Pos"  (. song position)
        }
      }))

  (defn dict->mpdstr [self dict]
    (.rstrip (reduce (fn [rest pair]
                       (+ rest
                          (.format "{}: {}" (first pair) (last pair))
                          mpd.DELIMITER))
                      (.items (self.convert-dict dict)) "") mpd.DELIMITER))

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
        (cond
          [(isinstance resp dict) (self.dict->mpdstr resp)]
          [(isinstance resp Song) (self.convert-song resp)]
          [True resp]))
      (raise (NotImplementedError (% "%s has not ben implemented" cmd.name))))))

(setv commands (Commands))
