(import [smrt [comm]])

(defn all-function-status [sock]
    (comm.init-comm sock "\x35\x00\x00\x00")
    (comm.single-packet sock))

(defn function-status [sock id]
  (let [[status (all-function-status sock)]]
    (get
     (dict-comp
      (get f 0) (get f -1)
      [f (list-comp
          (f.split ",")
          [f (-> (status.rstrip ";") (.split ";"))])])
     id)))

(defn human-readable-function-status [status functions]
  (list-comp
   [(get f 0) (get (->> (get f 0) (get functions)) "name") (get f -1)]
   [f (list-comp
       (f.split ",")
       [f (-> (status.rstrip ";") (.split ";"))])]))
