(import [protocol [commands]]
        [protocol.util :as util])
(require [hy.contrib.walk [let]])

(with-decorator (commands.add "currentsong")
  (defn current-song [player beets cmd]
    (util.current-song player beets)))

(with-decorator (commands.add "status")
  (defn status [player beets cmd]
    None))
