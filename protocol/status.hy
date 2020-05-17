(import [protocol [commands]]
        [protocol.util :as util])
(require [hy.contrib.walk [let]]
         [hy.extra.anaphoric [*]])

(with-decorator (commands.add "currentsong")
  (defn current-song [ctx args]
    (with (playlist ctx.playback)
      (.current playlist))))

(with-decorator (commands.add "status")
  (defn status [ctx args]
    (with (playlist ctx.playback)
      (let [mode (. playlist mode)
            song (.current playlist)
            time (.time ctx.playback)]
        {#**
          {
            "volume"         100
            "repeat"         (get mode :repeat)
            "random"         (get mode :random)
            "single"         (get mode :single)
            "consume"        (get mode :consume)
            "playlistlength" (playlist.psize)
            "state"          (ctx.playback.state)
            "elapsed"        (ap-if time (first it))
            "duration"       (ap-if time (last it))
            "time"           (ap-if time (.join ":" (map (fn [v] (str (round v))) time)))
          }
         #**
          (if song
            {
              "song"           (. song position)
              "songid"         (get (. song metadata) "Id")
            } {})
        }))))
