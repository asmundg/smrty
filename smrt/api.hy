(require hy.contrib.loop)
(import re)
(import socket)
(import string)

(defn controllers []
  (let [[sock (socket.socket socket.AF_INET socket.SOCK_DGRAM)]]
    (sock.setsockopt socket.SOL_SOCKET socket.SO_BROADCAST 1)
    (sock.settimeout 1)
    (sock.bind (, "" 48006))
    (while True
      (sock.sendto "Config MG Connect" (, "255.255.255.255" 48005))
      (try
       (yield (get (sock.recvfrom 1024) 1))
       (catch [e socket.timeout])))))

(defn controller []
  (nth (controllers) 0))

(defn strlen [header]
  (if (< (ord (get header 1)) 9)
    (+ (ord (get header 0)) (* (- (ord (get header 1)) 1) 128))
    (ord (get header 0))))

(defn single-packet [sock]
  (let [[header (sock.recv 2 socket.MSG_WAITALL)]
        [length (strlen header)]]
    (.decode
     (if (< length 128)
       (+ (get header 1) (sock.recv (- length 1) socket.MSG_WAITALL))
       (sock.recv length socket.MSG_WAITALL))
     "utf-8")))

(defn all-packets [sock]
  (while True
    (yield (single-packet sock))))

(defn config-payload [sock]
  (list (take-while (fn [data] (none? (re.search "\[Lock=[a-f0-9]+\]" data)))
                    (all-packets sock))))

(defn connected-socket [address]
  (let [[sock (socket.socket socket.AF_INET socket.SOCK_STREAM)]]
    (sock.connect address)
    sock))

(defn init-comm [sock header]
  (sock.send header)
  (let [[response (sock.recv 1024)]]
    (if-not (= response header)
            (throw (Exception ("Header mismatch {}".format (list response)))))))

(defn config [sock address]
    (init-comm sock "\x46\x00\x00\x00")
    (sock.recv 1024)
    (config-payload sock))

(defn function-status [sock address]
    (init-comm sock "\x35\x00\x00\x00")
    (single-packet sock))

(defn human-readable-function-status [status functions]
  (list-comp
   [(get (->> (get f 0) (get functions)) "name") (get f -1)]
   [f (list-comp
       (f.split ",")
       [f (-> (status.rstrip ";") (.split ";"))])]))

(defn functions [conf]
  (dict-comp (get f "id") f
             [f (list-comp (func f)
                           [f (function-sections conf)])]))

(defn function-sections [conf]
  "Given a CG config list, return a list of config sections, each
   containing a Fx description

   [\"foo\" \"FxType=Fx_AnaLink_Lux\" \"FxName=Foo\"\"FxEnd\"]
   =>
   [\"FxType=Fx_AnaLink_Lux\nFxName=Foo\"]"
  (loop
   [[c conf] [funcs []]]
   (if (empty? c)
     (list (reversed funcs))
     (if (.startswith (car c) "FxType")
       (recur (cdr c) (cons (function-section c) funcs))
       (recur (cdr c) funcs)))))

(defn function-section [conf]
  "Given a CG config list, return a newline-joined string from the first
   element up to the corresponding FxEnd, exclusive

   [\"FxType=Fx_AnaLink_Lux\" \"FxName=Foo\"\"FxEnd\"]
   =>
   \"FxType=Fx_AnaLink_Lux\nFxName=Foo\""
  (-> (slice conf
             0
             (.index conf "FxEnd"))
      (string.join "\n")))

(defn func [fxstring]
  {"id" (-> (re.search "FxId=(.*)" fxstring re.MULTILINE) (.group (int 1)))
   "type" (-> (re.search "FxType=(.*)" fxstring re.MULTILINE) (.group (int 1)))
   "name" (-> (re.search "FxName=(.*)" fxstring re.MULTILINE) (.group (int 1)))})

(defclass Func []
  [[--init-- (fn [self id type name]
              (setv self.id id)
              (setv self.type type)
              (setv self.name name)
              None)]])
