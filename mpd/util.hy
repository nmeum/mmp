(require [hy.contrib.loop [loop]])
(require [hy.contrib.walk [let]])

(defclass Reader [object]
  (defn --init-- [self file]
    (setv self.file file))

  (defn list-start? [self line]
    (or (= line "command_list_begin\n")
        (= line "command_list_ok_begin\n")))

  (defn list-end? [self line]
    (= line "command_list_end\n"))

  (defn --call-- [self]
    (loop [[str ""] [list False]]
      (let [line (self.file.readline)]
        (cond
          [(self.list-start? line)
           (recur (+ str line) True)]
          [list
           (if (self.list-end? line)
             (+ str line)
             (recur (+ str line) list))]
          [True line])))))
