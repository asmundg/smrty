(require hy.contrib.loop)

(import requests)
(import [smrt [status]])

(defn light-on [address sock func function-map]
  (if (= (get (status.all-function-status sock function-map) func) "0")
    (requests.get (.format "http://{}/check.asp?q={}||light.asp" (get address 0) (get function-map func)))
    null))

(defn light-off [address sock func function-map]
  (if (= (get (status.all-function-status sock function-map) func) "1")
    (requests.get (.format "http://{}/check.asp?q={}||light.asp" (get address 0) (get function-map func)))
    null))

