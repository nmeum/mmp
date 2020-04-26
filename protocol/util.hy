(import [playback.playlist [Song]])
(require [hy.contrib.walk [let]]
         [hy.extra.anaphoric [*]])

;; Mapping of beets tag names to MPD tag names.
;; See: src/tag/Names.c in MPD source.
(setv MPD-TAG-NAMES {
    "title"        "Title"
    "artist"       "Artist"
    "album"        "Album"
    "genre"        "Genre"
    "track"        "Track"
    "disc"         "Disc"
    "albumartist"  "AlbumArtist"
  })

(defn beets->song [metadata]
  (defn convert-meta [metadata]
    (reduce (fn [dict pair]
              (if (in (first pair) MPD-TAG-NAMES)
                (assoc dict (get MPD-TAG-NAMES (first pair)) (last pair)))
              dict)
            (.items metadata) {}))

  (Song (get metadata "path")
        (convert-meta metadata)))
