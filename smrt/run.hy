(import pprint)
(import sys)
(import time)

(import [smrt [comm config control status]])

(let [[controller (comm.controller)]
      [sock (comm.connected-socket controller)]
      [functions (config.functions (config.config sock))]]
  (cond [(= (get sys.argv 1) "functions") (pprint.pprint (sorted (functions.keys)))]
        [(= (get sys.argv 1) "on")
         (control.light-on controller sock (get sys.argv 2) functions)]
        [(= (get sys.argv 1) "off")
         (control.light-off controller sock (get sys.argv 2) functions)]))
