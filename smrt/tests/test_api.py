import hy  # qa
from smrt import api

fx = ['[FX CONFIG]',
      'FxType=Fx_Dimmer',
      'FxId=8',
      'FxName=Test Dimmer',
      'FxUsage=6',
      'DimOpMode=0',
      'AutoSceneLow=1',
      'AutoSceneHigh=4',
      'PirSwOn=0',
      'PIRdelay=0',
      'OnLevel=300',
      'OffLevel=500',
      'LUXmin=5',
      'LUXmax=300000',
      'LUXscale=2',
      'DimUpDown=0,211,0,0,14,0,0,45',
      'DimCtrl1=0,212,0,0,14,1,0,45',
      'DimCtrl2=0,213,0,0,14,2,0,45',
      'DimOutStatus=0,214,0,0,14,3,0,45',
      'FxEnd',
      'FxType=Fx_Dimmer',
      'FxId=9',
      'FxName=Test Dimmer #2',
      'FxUsage=6',
      'DimOpMode=0',
      'AutoSceneLow=1',
      'AutoSceneHigh=4',
      'PirSwOn=0',
      'PIRdelay=0',
      'OnLevel=300',
      'OffLevel=500',
      'LUXmin=5',
      'LUXmax=300000',
      'LUXscale=2',
      'DimUpDown=0,211,0,0,14,0,0,45',
      'DimCtrl1=0,212,0,0,14,1,0,45',
      'DimCtrl2=0,213,0,0,14,2,0,45',
      'DimOutStatus=0,214,0,0,14,3,0,45',
      'FxEnd']


def test_functions():
    assert api.functions(fx) == {
        '8': dict(name='Test Dimmer', type='Fx_Dimmer', id='8'),
        '9': dict(name='Test Dimmer #2', type='Fx_Dimmer', id='9')}


def test_human_readable_function_status():
    assert (
        api.human_readable_function_status(
            '8,0,0,1;9,0,0,0;',
            {'8': dict(name='foo'), '9': dict(name='bar')})
        == [['foo', '1'], ['bar', '0']])
