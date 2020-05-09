(import mpd
        [protocol [commands]]
        [protocol.util :as util])
(require [hy.contrib.walk [let]])

(with-decorator (commands.add "tagtypes")
  (defn tagtypes [ctx args]
    (reduce (fn [lst key]
              (if (not (in key util.MPD-BASIC-TAGS))
                (.append lst (.format "tagtype: {}" key)))
              lst)
            (.values util.MPD-TAG-NAMES) [])))
