(import [protocol [commands]]
  [mpd.exceptions [*]])
(require [hy.extra.anaphoric [*]]
  [hy.contrib.walk [let]])

(with-decorator (commands.add "add")
  ;; Requiries https://github.com/beetbox/beets/pull/3567 to work correctly
  (defn add [playback beets args]
    (let [path     (first args)
          query    (.format "path:{}" path)
          items    (.query-items beets query)
          no-exist (MPDException ACKError.NO_EXIST "no such file")]
      (if items
        (let [playlist playback.playlist]
          (try
            (ap-each items (.add-song playlist (get it "path")))
          (except [FileNotFoundError]
            (raise no-exist))))
        (raise no-exist)))))
