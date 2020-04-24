(import [urllib.request [Request urlopen]]
        [urllib.parse [urljoin]]
        [urllib.error [HTTPError]]
        urllib.parse
        json)
(require [hy.contrib.walk [let]])

(defclass Client []
  (defn --init-- [self url]
    (setv self.base-url url)
    (setv self.headers {
      "Content-Type" "application/json"
      "Accept" "application/json"
    }))

  (defn _send_req [self path &optional [method None] [data None]]
    (let [url (urljoin self.base-url (urllib.parse.quote path))
          req (Request url :headers self.headers
                           :method method
                           :data data)]
      (try
        (with (resp (urlopen req))
          (json.loads (.read resp)))
      (except [err [HTTPError]]
        (if (= err.code 404)
          None
          (raise))))))

  (defn find-item [self path]
    (self._send_req (+ "/item/path/" path))))
