(import [urllib.request [Request urlopen]]
        [urllib.parse [urljoin]]
        [urllib.error [HTTPError]]
        urllib.parse
        json)
(require [hy.contrib.walk [let]])

(defclass Client []
  (defn __init__ [self url]
    (setv self.base-url url)
    (setv self.headers {
      "Content-Type" "application/json"
      "Accept" "application/json"
    }))

  (defn -send-req [self path &optional [method None] [data None]]
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

  (defn find-item [self id]
    (cond
      [(isinstance id str)
        (.-send-req self (.format "/item/path/{}" id))]
      [(isinstance id int)
        (.-send-req self (.format "/item/{}" id))]
      [True (raise (TypeError "invalid argument type"))]))

  (defn query-items [self query]
    (get (.-send-req self (+ "/item/query/" query)) "results"))

  ;; Requiries https://github.com/beetbox/beets/pull/3567
  (defn query-path [self path]
    (.query-items self (.format "path:{}" (.replace path "/" "\\")))))
