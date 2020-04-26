(import [protocol [commands]]
  [mpd.exceptions [*]])
(require [hy.extra.anaphoric [*]]
  [hy.contrib.walk [let]])

(with-decorator (commands.add "play")
  (defn add [playback beets args]
    (if args
      (try
        (playback.play (first args))
        (except [e IndexError]
          (raise (MPDException ACKError.ARG "Bad song index"))))
      (playback.play))
    None))
