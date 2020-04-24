(import [protocol [commands]])

(with-decorator (commands.add "currentsong")
  (defn current-song [songs beets cmd]
    None))

(with-decorator (commands.add "status")
  (defn status [songs beets cmd]
    None))
