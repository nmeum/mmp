(import [protocol [commands]]
  [mpd.exceptions [*]]
  [protocol.util :as util])
(require [hy.extra.anaphoric [*]]
  [hy.contrib.walk [let]])

(with-decorator (commands.add "add")
  (defn add [ctx args]
    (let [path     (first args)
          items    (.query-path ctx.beets path)
          no-exist (MPDException ACKError.NO_EXIST "no such file")]
      (if items
        (with (playlist ctx.playback)
          (try
            (ap-each items (.add playlist (util.create-song it)))
          (except [FileNotFoundError]
            (raise no-exist))))
        (raise no-exist)))))

(with-decorator (commands.add "playlistinfo")
  (defn playlist-info [ctx args]
    ctx.playback))
