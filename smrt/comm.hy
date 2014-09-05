(import socket)

(defn connected-socket [address]
  (let [[sock (socket.socket socket.AF_INET socket.SOCK_STREAM)]]
    (sock.connect address)
    sock))

(defn init-comm [sock header]
  (sock.send header)
  (let [[response (sock.recv 1024)]]
    (if-not (= response header)
            (throw (Exception ("Header mismatch {}".format (list response)))))))

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

(defn packet-length [header]
  (if (= (ord (get header 0)) 128)
    130
    (if (< (ord (get header 1)) 9)
      (+ (ord (get header 0)) (* (- (ord (get header 1)) 1) 128))
      (ord (get header 0)))))

(defn single-packet [sock]
  (let [[header (sock.recv 2 socket.MSG_WAITALL)]
        [length (packet-length header)]]
    (if (< length 128)
      (+ (get header 1) (sock.recv (- length 1) socket.MSG_WAITALL))
      (sock.recv length socket.MSG_WAITALL))))

(defn all-packets [sock]
  (while True
    (yield (single-packet sock))))
