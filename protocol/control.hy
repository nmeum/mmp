(import [protocol [commands]]
  [mpd.exceptions [*]])
(require [hy.extra.anaphoric [*]]
  [hy.contrib.walk [let]])

(with-decorator (commands.add "play")
  (defn play [ctx args]
    (if args
      (try
        (ctx.playback.play (first args))
        (except [e IndexError]
          (raise (MPDException ACKError.ARG "Bad song index"))))
      (ctx.playback.play))
    None))
