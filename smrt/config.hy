(require hy.contrib.loop)
(import re)
(import string)

(import [smrt [comm]])

(defn config-payload [sock]
  (list (take-while (fn [data] (none? (re.search "\[Lock=[a-f0-9]+\]" data)))
                    (comm.all-packets sock))))

(defn config [sock address]
    (comm.init-comm sock "\x46\x00\x00\x00")
    (sock.recv 1024)
    (config-payload sock))

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
