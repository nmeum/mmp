(import [protocol [commands]]
        [protocol.util :as util])
(require [hy.contrib.walk [let]])

(with-decorator (commands.add "repeat")
  (defn repeat [playback beets args]
    (with (playlist playback)
      (assoc (. playlist mode) :repeat (first args))
      None)))
