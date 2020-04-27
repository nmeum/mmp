(import [playback.playlist [Song]]
  [datetime [datetime]])
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
    "id"           "Id"
    ;; TODO: Time
    "length"       "duration"
    "mtime"        "Last-Modified"
  })

;; Functions for converting a value of the given beets tag name to
;; the representation used by the corresponding MPD tag (see above).
(setv conversion-funcs {
  "length" (fn [v] (round v 3))
  "mtime"  (fn [v] (datetime.fromtimestamp (int v)))
})

(defn beets->song [metadata]
  (defn convert-meta [metadata]
    (defn is-unset [value]
      (try
        (or (is None value) (= (len value) 0))
        (except [TypeError] False)))

  (defn convert-value [tag value]
    (try
      ((get conversion-funcs tag) value)
      (except [KeyError] value)))

    (reduce (fn [dict pair]
              (if (and (in (first pair) MPD-TAG-NAMES)
                       (not (is-unset (last pair))))
                (assoc dict (get MPD-TAG-NAMES (first pair))
                            (convert-value (first pair) (last pair))))
              dict)
            (.items metadata) {}))

  (Song (get metadata "path")
        (convert-meta metadata)))
