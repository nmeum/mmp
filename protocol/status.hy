(import [protocol [commands]]
        [protocol.util :as util])
(require [hy.contrib.walk [let]])

(with-decorator (commands.add "currentsong")
  (defn current-song [playback beets args]
    (util.current-song playback beets)))

(with-decorator (commands.add "status")
  (defn status [playback beets args]
    (let [playlist playback.playlist
          mode (playlist.get-mode)
          state (with (player playback) (player.state))]
      {
        "volume"         100
        "repeat"         (get mode :repeat)
        "random"         (get mode :random)
        "single"         (get mode :single)
        "consume"        (get mode :consume)
        "playlistlength" (playlist.psize)
        "state"          state ;; TODO: check if state is a valid MPD state
      })))
