(import mpd
        [protocol [commands]]
        [protocol.util :as util])
(require [hy.contrib.walk [let]]
         [hy.extra.anaphoric [*]])

;; TODO: tagtypes code could use sets instead of lists.

(defn list-tagtypes [ctx]
  (reduce (fn [lst key]
            (if (and (not (in key util.MPD-BASIC-TAGS))
                     (not (in key ctx.disabled-tags)))
              (.append lst (.format "tagtype: {}" key)))
            lst)
          (.values util.MPD-TAG-NAMES) []))

(defn disable-tagtypes [ctx tags]
  (ctx.disabled-tags.extend
    (filter (fn [tag]
              (and (not (in tag util.MPD-BASIC-TAGS))
                   (not (in tag ctx.disabled-tags))))
            tags)))

(defn enable-tagtypes [ctx tags]
  (ap-each tags
    (if (in it (. ctx disabled-tags))
      (.remove (. ctx disabled-tags) it))))

(defn clear-tagtypes [ctx]
  (ctx.disabled-tags.extend
    (filter (fn [tag] (not (in tag util.MPD-BASIC-TAGS)))
            (.values util.MPD-TAG-NAMES))))

(defn all-tagtypes [ctx]
  (.clear ctx.disabled-tags))

(with-decorator (commands.add "tagtypes")
  (defn tagtypes [ctx args]
    (if (not args)
      (list-tagtypes ctx)
      (cond
        [(= "disable" (first args))
         (disable-tagtypes ctx (list (rest args)))]
        [(= "enable" (first args))
         (enable-tagtypes ctx (list (rest args)))]
        [(= "clear" (first args))
         (clear-tagtypes ctx)]
        [(= "all" (first args))
         (all-tagtypes ctx)]
        [True (raise NotImplementedError)]))))
