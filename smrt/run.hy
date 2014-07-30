(import pprint)
(import time)

(import [smrt [comm config control status]])

(print (comm.controller))
(let [[controller (comm.controller)]
      [sock (comm.connected-socket controller)]]
  (let [[functions (config.functions (config.config sock))]
        [stats (status.all-function-status sock)]]
    (pprint.pprint (status.human-readable-function-status
                    stats
                    functions))
    (pprint.pprint (status.function-status sock "41"))
    (let [[id (config.function-id-from-name "1. etg Stue - Dimmer Sone 1" functions)]]
      (control.light-on controller sock id)
      (time.sleep 2)
      (control.light-off controller sock id))))
