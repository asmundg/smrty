(import pprint)
(import [smrt [api]])

(print (api.controller))
(let [[controller (api.controller)]
      [sock (api.connected-socket controller)]
      [functions (api.functions (api.config sock controller))]
      [status (api.function-status sock controller)]]
  (pprint.pprint (api.human-readable-function-status
                  status
                  functions)))
