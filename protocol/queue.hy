(import [protocol [commands]]
  [mpd.exceptions [*]]
  [protocol.util :as util])
(require [hy.extra.anaphoric [*]]
  [hy.contrib.walk [let]])

(with-decorator (commands.add "add")
  (defn add [ctx args]
    (let [items (-> (with [(.transaction (. ctx beets))]
                        (.items (. ctx beets)
                                (.format "path:{}" (first args))))
                    list)]
      (if items
        (with (playlist ctx.playback)
          (try
            (ap-each items (.add playlist (util.create-song it)))
          (except [FileNotFoundError]
            (raise MPDNotFoundError))))
        (raise MPDNotFoundError)))))

;; TODO: Handle case where the delete song is the current song (requires
;; player to skip to the next song in the playlist or stop if none).
(with-decorator (commands.add "delete")
  (defn delete [ctx args]
    (with (playlist ctx.playback)
      (try
        (.remove ctx.playback (.to-range (first args) (.psize playlist)))
        (except [IndexError]
          (raise MPDBadIndexError))))))

;; TODO: Respect optional song position argument.
(with-decorator (commands.add "playlistinfo")
  (defn playlist-info [ctx args]
    ctx.playback))
