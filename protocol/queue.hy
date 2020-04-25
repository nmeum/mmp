(import [protocol [commands]]
  [mpd.exceptions [*]])
(require [hy.extra.anaphoric [*]]
  [hy.contrib.walk [let]])

(with-decorator (commands.add "add")
  (defn add [playback beets args]
    (let [path  (first args)
          query (.format "path:{}" path)
          items (.query-items beets query)]
      (if items
        (let [playlist playback.playlist]
          (ap-each items (.add-song playlist (get it "path"))))
        (raise (MPDException ACKError.NO_EXIST "no such file"))))))
