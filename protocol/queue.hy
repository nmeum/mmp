(import [protocol [commands]]
  [mpd.exceptions [*]])
(require [hy.extra.anaphoric [*]]
  [hy.contrib.walk [let]])

(with-decorator (commands.add "add")
  (defn add [playback beets args]
    (let [path     (first args)
          items    (.query-path beets path)
          no-exist (MPDException ACKError.NO_EXIST "no such file")]
      (if items
        (with (playlist playback)
          (try
            (ap-each items (.add playlist (get it "path")))
          (except [FileNotFoundError]
            (raise no-exist))))
        (raise no-exist)))))
