(import argparse mpd threading signal
  [mpd.server [Server]]
  [protocol [commands status]]
  [playback.playback [Playback]]
  [beets.client [Client]])
(require [hy.contrib.walk [let]])

;; The socketserver needs to be closed from a different thread. This
;; thread blocks until a signal is received then closes the server.
(defclass CleanupThread [threading.Thread]
  (defn --init-- [self socket-server]
    (setv self.server socket-server)
    (setv self.lock (threading.Semaphore 0))
    (signal.signal signal.SIGINT
      (fn [signal frame] (self.lock.release)))
    (.--init-- threading.Thread self))

  (defn run [self]
    (self.lock.acquire)
    (self.server.shutdown)))

(defn start-server [addr port playback beets]
  (let [handler  (fn [cmd] (commands.call playback beets cmd))]
    (with [server (Server (, addr port) handler)]
      (.start (CleanupThread server))
      (server.serve-forever))))

(defmain [&rest args]
  (let [parser (argparse.ArgumentParser)]
    (parser.add-argument "URL" :type str
      :help "URL of the beets webapi instance")
    (parser.add-argument "-p" :type int :metavar "PORT"
      :default 6600 :help "TCP port used by the MPD server")
    (parser.add-argument "-a" :type str :metavar "ADDR"
      :default "localhost" :help "Address the MPD server binds to")
    (let [args (parser.parse-args)]
      (start-server args.a args.p (Playback) (Client args.URL))))
  0)
