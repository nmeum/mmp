(import mpd
  [playback.playback [Playback]]
  [playback.playlist [Song]])
(require [hy.contrib.walk [let]])

(defclass Commands [object]
  (defn __init__ [self]
    (setv self.handlers {}))

  (defn _serialize-dict [self dict &optional exclude]
    (defn _serialize-values [dict]
      (dfor (, key value) (.items dict)
        [key (if (isinstance value bool)
               (if value 1 0)
               value)]))

    (.rstrip (reduce (fn [rest pair]
                       (if (and (not (is None exclude))
                                (in (first pair) exclude))
                         rest
                         (+ rest
                            (.format "{}: {}" (first pair) (last pair))
                            mpd.DELIMITER)))
                      (.items (_serialize-values dict)) "") mpd.DELIMITER))

  (defn _serialize-list [self list]
    (.join mpd.DELIMITER list))

  (defn _serialize-song [self song filter]
    (._serialize-dict self
      {#**
        {
          "file" (. song path)
          "Pos"  (. song position)
        }
       #**
        (. song metadata)
      } filter))

  (defn _serialize-playback [self playback filter]
    (with (playlist playback)
      (reduce (fn [string song]
                (+ string (._serialize-song self song filter)))
              playlist "")))

  (defn _serialize [self ctx value]
    (cond
      [(isinstance value dict)
        (._serialize-dict self value)]
      [(isinstance value list)
        (._serialize-list self value)]
      [(isinstance value Song)
        (._serialize-song self value ctx.disabled-tags)]
      [(isinstance value Playback)
        (._serialize-playback self value ctx.disabled-tags)]
      [True value]))

  (defn add [self name]
    (fn [func]
      (if (in name self.handlers)
        (raise (ValueError (% "%s already registered" name)))
        (do
          (assoc self.handlers name func)
          func))))

  (defn handle [self ctx cmd]
    (if (in cmd.name self.handlers)
      (let [handler (get self.handlers cmd.name)
            resp    (handler ctx cmd.args)]
        (._serialize self ctx resp))
      (raise (NotImplementedError (% "%s has not ben implemented" cmd.name))))))

(setv commands (Commands))
