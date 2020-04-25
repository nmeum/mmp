(import [protocol [commands]]
        [protocol.util :as util])
(require [hy.contrib.walk [let]])

(with-decorator (commands.add "currentsong")
  (defn current-song [playback beets cmd]
    (util.current-song playback beets)))

(with-decorator (commands.add "status")
  (defn status [playback beets cmd]
    None))
