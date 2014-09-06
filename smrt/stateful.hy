(require hy.contrib.loop)

(import datetime)
(import pprint)
(import sys)
(import time)

(import yaml)
(import [smrt [comm config control status]])

(defn last-triggered [func stats now]
  (- now (.get stats func (datetime.datetime 1 1 1))))

(defn should-trigger [func stats now]
  (list-comp trigger [trigger (.get func "triggers" [])]
             (cond [(.get trigger "until")
                    (<= (last-triggered (get trigger "name") stats now)
                        (datetime.timedelta 0 (get trigger "until")))])))

(let [[controller (comm.controller)]
      [sock (comm.connected-socket controller)]
      [functions (config.functions (config.config sock))]
      [conf (yaml.load (open "conf.yml"))]]
  (loop [[stat {}]]
    (let [[now (datetime.datetime.now)]
          [new-status (status.all-function-status sock functions)]
          [new-stat (dict-comp func now [func new-status] (= (get new-status func) "1"))]]
      (stat.update new-stat)
      (pprint.pprint stat)
      (for [func conf]
        (if (= (.get func "dim") 100)
          (if (should-trigger func stat now)
            (control.light-on controller sock (get func "name") functions)
            (control.light-off controller sock (get func "name") functions))))
      (recur stat))))
