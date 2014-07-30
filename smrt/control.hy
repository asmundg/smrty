(require hy.contrib.loop)

(import requests)
(import [smrt [status]])

(defn light-on [address sock id]
  (if (= (status.function-status sock id) "0")
    (requests.get (.format "http://{}/check.asp?q={}||light.asp" (get address 0) id))
    null))

(defn light-off [address sock id]
  (if (= (status.function-status sock id) "1")
    (requests.get (.format "http://{}/check.asp?q={}||light.asp" (get address 0) id))
    null))

