(import [protocol [commands]]
        [protocol.util :as util])
(require [hy.contrib.walk [let]])

(with-decorator (commands.add "currentsong")
  (defn current-song [playback beets cmd]
    (util.current-song playback beets)))

(with-decorator (commands.add "status")
  (defn status [playback beets cmd]
    (let [mode (playback.playlist.get-mode)
          state (with (player playback) (player.state))]
      {
        "volume"         100
        "repeat"         (get mode :repeat)
        "random"         (get mode :random)
        "single"         (get mode :single)
        "consume"        (get mode :consume)
        "playlistlength" 0
        "state"          state ;; TODO: check if state is a valid MPD state
      })))
