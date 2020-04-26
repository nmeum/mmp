(import [protocol [commands]]
        [protocol.util :as util])
(require [hy.contrib.walk [let]])

(with-decorator (commands.add "currentsong")
  (defn current-song [playback beets args]
    (with (playlist playback)
      (let [path (.current playlist)]
        (if (is None path)
          None
          (util.convert-song (.find-item beets path)))))))

(with-decorator (commands.add "status")
  (defn status [playback beets args]
    (with (playlist playback)
      (let [mode (. playlist mode)]
        {
          "volume"         100
          "repeat"         (get mode :repeat)
          "random"         (get mode :random)
          "single"         (get mode :single)
          "consume"        (get mode :consume)
          "playlistlength" (playlist.psize)
          "state"          (playback.state)
        }))))
