(import [protocol [commands]]
        [protocol.util :as util])
(require [hy.contrib.walk [let]])

(with-decorator (commands.add "currentsong")
  (defn current-song [playback beets args]
    (with (playlist playback)
      (.current playlist))))

(with-decorator (commands.add "status")
  (defn status [playback beets args]
    (with (playlist playback)
      (let [mode (. playlist mode)
            song (.current playlist)]
        {#**
          {
            "volume"         100
            "repeat"         (get mode :repeat)
            "random"         (get mode :random)
            "single"         (get mode :single)
            "consume"        (get mode :consume)
            "playlistlength" (playlist.psize)
            "state"          (playback.state)
          }
         #**
          (if song
            {
              "song"           (. song position)
              "songid"         (get (. song metadata) "Id")
            } {})
        }))))
