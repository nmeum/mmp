#!/usr/bin/env hy

(import sys socket signal)

(when (< (len sys.argv) 2)
  (print (.format "USAGE: {} HOST PORT"
           (get sys.argv 0))
         :file sys.stderr)
  (sys.exit 1))

(signal.signal signal.SIGALRM
  (fn [signal frame] (sys.exit 1)))
(signal.alarm 30)

(setv addr (, (get sys.argv 1) (get sys.argv 2)))
(while True
  (try
    (.close (socket.create_connection addr))
    (except [OSError] (continue))
    (else (sys.exit 0))))
