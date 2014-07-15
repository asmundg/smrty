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
    ((.
     (if (< length 128)
       (+ (get header 1) (sock.recv (- length 1)))
       (sock.recv length))
     decode) "utf-8")))

(defn all-packets [sock]
  (while True
    (yield (single-packet sock))))

(defn payload [sock]
  (string.join
   (take-while (fn [data] (none? (re.search "\[Lock=[a-f0-9]+\]" data)))
               (all-packets sock))
   "\n"))

(defn init-comm [sock header]
  (sock.send header)
  (let [[response (sock.recv 1024)]]
    (if-not (= response header)
            (throw (Exception ("Header mismatch {}".format (list response)))))))


(defn config [address]
  (let [[sock (socket.socket socket.AF_INET socket.SOCK_STREAM)]]
    (sock.connect address)
    (init-comm sock "\x46\x00\x00\x00")
    (sock.recv 1024)
    (payload sock)))

(print (controller))
(print (config (controller)))
