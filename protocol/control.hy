(import [protocol [commands]]
  [mpd.exceptions [*]])
(require [hy.extra.anaphoric [*]]
  [hy.contrib.walk [let]])

(with-decorator (commands.add "play")
  (defn add [playback beets args]
    (if args
      (playback.play-song (first args))
      (playback.play))
    None))
