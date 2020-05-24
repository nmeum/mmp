(import [enum [Enum]])

;; From src/protocol/Ack.hxx in mpd source
(defclass ACKError [Enum]
  (setv NOT_LIST 1)
  (setv ARG 2)
  (setv PASSWORD 3)
  (setv PERMISSION 4)
  (setv UNKNOWN 5)
  (setv NO_EXIST 50)
  (setv PLAYLIST_MAX 51)
  (setv SYSTEM 52)
  (setv PLAYLIST_LOAD 53)
  (setv UPDATE_ALREADY 54)
  (setv PLAYER_SYNC 55)
  (setv EXIST 56))

(defclass MPDException [Exception]
  (defn __init__ [self code msg &optional [lst-num 0] [cur-cmd ""]]
    (if (not (isinstance code ACKError))
      (raise (TypeError "Exception code must be an ACKError")))
    (setv self.code code)
    (setv self.msg msg)
    (setv self.lst-num lst-num)
    (setv self.cur-cmd cur-cmd))

  ;; Format: ACK [error@command_listNum] {current_command} message_text
  (defn __str__ [self]
    (% "ACK [%d@%d] {%s} %s" (, self.code.value self.lst-num
                                self.cur-cmd self.msg))))

(defclass MPDNotFoundError [MPDException]
  (defn __init__ [self]
    (.__init__ (super) ACKError.NO_EXIST "no such file")))
