(import [protocol [commands]]
  [mpd.exceptions [*]])
(require [hy.extra.anaphoric [*]]
  [hy.contrib.walk [let]])

(with-decorator (commands.add "pause")
  (defn pause [ctx args]
    (if args
      (if (first args)
        (.pause ctx.playback)
        (.play ctx.playback))
      (raise (NotImplementedError "Pause command without argument")))))

(with-decorator (commands.add "play")
  (defn play [ctx args]
    (if args
      (try
        (ctx.playback.play (first args))
        (except [e IndexError]
          (raise (MPDException ACKError.ARG "Bad song index"))))
      (ctx.playback.play))
    None))

(with-decorator (commands.add "stop")
  (defn stop [ctx args]
    (.stop (. ctx playback))))
