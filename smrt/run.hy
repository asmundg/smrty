(import pprint)
(import [smrt [config comm status]])

(print (comm.controller))
(let [[controller (comm.controller)]
      [sock (comm.connected-socket controller)]
      [functions (config.functions (config.config sock controller))]
      [stats (status.function-status sock controller)]]
  (pprint.pprint (status.human-readable-function-status
                  stats
                  functions)))
