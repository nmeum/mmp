(import [protocol [commands]]
        [protocol.util :as util])
(require [hy.contrib.walk [let]])

(with-decorator (commands.add "currentsong")
  (defn current-song [songs beets cmd]
    (util.current-song songs beets)))

(with-decorator (commands.add "status")
  (defn status [songs beets cmd]
    None))
