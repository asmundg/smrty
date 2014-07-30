(import [smrt [comm]])

(defn function-status [sock address]
    (comm.init-comm sock "\x35\x00\x00\x00")
    (comm.single-packet sock))

(defn human-readable-function-status [status functions]
  (list-comp
   [(get f 0) (get (->> (get f 0) (get functions)) "name") (get f -1)]
   [f (list-comp
       (f.split ",")
       [f (-> (status.rstrip ";") (.split ";"))])]))
