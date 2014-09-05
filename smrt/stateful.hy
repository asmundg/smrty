(require hy.contrib.loop)

(import datetime)
(import pprint)
(import sys)
(import time)

(import yaml)
(import [smrt [comm config control status]])

(let [[controller (comm.controller)]
      [sock (comm.connected-socket controller)]
      [functions (config.functions (config.config sock))]
      [conf (yaml.load (open "conf.yml"))]]
  (loop [[stat {}]]
    (let [[now (datetime.datetime.now)]
          [new-status (status.all-function-status sock)]
          [timestamp-status (dict-comp id now [id new-status] (= (get new-status id) "1"))]]
      (stat.update timestamp-status)
      (pprint.pprint stat)
      (recur stat))))
