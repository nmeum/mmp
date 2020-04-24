(import mpd socketserver
  [mpd.exceptions [*]]
  [mpd.parser [parse-command]])
(require [hy.contrib.walk [let]])

(defclass Handler [socketserver.BaseRequestHandler]
  (defn send-resp [self resp]
    (self.request.sendall (.encode (+ (str resp) mpd.DELIMITER))))

  (defn dispatch-single [self cmd]
    (let [resp (self.server.callable cmd)]
      (if resp (self.send-resp resp))))

  (defn dispatch-list [self list]
    (setv ok-list? (= list.name "command_list_ok_begin"))
    (for [cmd list.args]
      (self.dispatch-single cmd)
      (if ok-list? (self.send-resp "list_OK"))))

  (defn dispatch [self input]
    (try
      (setv cmd (parse-command input))
      (except [ValueError]
        (self.send-resp (MPDException ACKError.UNKNOWN "syntax error"))
        (return)))
    (try
      (if (cmd.list?)
        (self.dispatch-list cmd)
        (self.dispatch-single cmd))
      (except [e MPDException]
        (self.send-resp e))
      (else (self.send-resp "OK"))))

  (defn handle [self]
    (self.send-resp (% "OK MPD %s" mpd.VERSION))
    (with [file (self.request.makefile)]
      (for [input (iter (mpd.util.Reader file) "")]
        (self.dispatch input)))))

(defclass Server [socketserver.ThreadingTCPServer]
  (defn --init-- [self addr callable]
    (.--init-- socketserver.ThreadingTCPServer self addr Handler)
    (setv self.daemon_threads True)
    (setv self.callable callable)))
