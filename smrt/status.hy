(import [smrt [comm]])

(defn invert [map]
  (dict-comp (get map key) key [key map]))

(defn all-function-status [sock function-map]
  """
   function map is a {name id} mapping
  """
  (let [[id-to-func (invert function-map)]]
    (comm.init-comm sock "\x35\x00\x00\x00")
    (let [[status (comm.single-packet sock)]]
      (dict-comp
       (get id-to-func (get f 0)) (get f -1)
       [f (list-comp
           (f.split ",")
           [f (-> (status.rstrip ";") (.split ";"))])]))))

(defn all-analink-status [sock]
  (comm.init-comm sock "\x34\x00\x00\x00")
  (comm.single-packet sock))

(defn all-digital-status [sock]
  (comm.init-comm sock "\x33\x00\x00\x00")
  (comm.single-packet sock))

(defn function-status [sock id]
  "Function status looks like 8,0,0,1;9,0,0,0
   (FUNCTION_ID,_,_,FUNCTION_STATUS;) where FUNCTION_STATUS is 0 or
   1."
  (let [[status (all-function-status sock)]]
    (get status id)))

(defn human-readable-function-status [status functions]
  (list-comp
   [(get f 0) (get (get functions (get f 0)) "name") (get f -1)]
   [f (list-comp
       (f.split ",")
       [f (-> (status.rstrip ";") (.split ";"))])]))
