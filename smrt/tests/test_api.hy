(import [smrt [api]])

(setv fx ["[FX CONFIG]"
          "FxType=Fx_Dimmer"
          "FxId=8"
          "FxName=Test Dimmer"
          "FxUsage=6"
          "DimOpMode=0"
          "AutoSceneLow=1"
          "AutoSceneHigh=4"
          "PirSwOn=0"
          "PIRdelay=0"
          "OnLevel=300"
          "OffLevel=500"
          "LUXmin=5"
          "LUXmax=300000"
          "LUXscale=2"
          "DimUpDown=0,211,0,0,14,0,0,45"
          "DimCtrl1=0,212,0,0,14,1,0,45"
          "DimCtrl2=0,213,0,0,14,2,0,45"
          "DimOutStatus=0,214,0,0,14,3,0,45"
          "FxEnd"
          "FxType=Fx_Dimmer"
          "FxId=9"
          "FxName=Test Dimmer #2"
          "FxUsage=6"
          "DimOpMode=0"
          "AutoSceneLow=1"
          "AutoSceneHigh=4"
          "PirSwOn=0"
          "PIRdelay=0"
          "OnLevel=300"
          "OffLevel=500"
          "LUXmin=5"
          "LUXmax=300000"
          "LUXscale=2"
          "DimUpDown=0,211,0,0,14,0,0,45"
          "DimCtrl1=0,212,0,0,14,1,0,45"
          "DimCtrl2=0,213,0,0,14,2,0,45"
          "DimOutStatus=0,214,0,0,14,3,0,45"
          "FxEnd"])

(defn test-functions []
  (let [[res (api.functions fx)]]
    (print (. (get res 0) name))
    (assert (= (. (get res 0) name) "Test Dimmer"))
    (assert (= (. (get res 1) name) "Test Dimmer #2"))))
