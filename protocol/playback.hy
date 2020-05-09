(import [protocol [commands]]
        [protocol.util :as util])
(require [hy.contrib.walk [let]])

(with-decorator (commands.add "repeat")
  (defn repeat [ctx args]
    (with (playlist ctx.playback)
      (assoc (. playlist mode) :repeat (first args))
      None)))
