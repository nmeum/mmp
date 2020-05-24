(import [protocol [commands]]
        [protocol.util :as util])
(require [hy.contrib.walk [let]])

;; TODO: Implement random and consume

(with-decorator (commands.add "single")
  (defn single [ctx args]
    (let [arg (first args)]
      (if (= arg "oneshot")
        (raise (NotImplementedError "oneshot mode not supported")))
      (with (playlist ctx.playback)
        (assoc (. playlist mode) :single
               (cond
                 [(= arg "1") True]
                 [(= arg "0") False]
                 [True (raise (ValueError "unexpected repeat argument"))]))))))

(with-decorator (commands.add "repeat")
  (defn repeat [ctx args]
    (with (playlist ctx.playback)
      (assoc (. playlist mode) :repeat (first args))
      None)))
