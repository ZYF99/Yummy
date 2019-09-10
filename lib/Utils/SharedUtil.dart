import 'package:flutter_sample/widget/LimitSettingDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedUtil{

  static Future<double> getLimit(int type) async {
    double _sliderTemp = 0;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (type == LimitSettingDialog.DAYLIMIT) {
      _sliderTemp = preferences.getDouble('dayLimit');
    } else {
      _sliderTemp = preferences.getDouble('monthLimit');
    }
    if (null == _sliderTemp) {
      if (type == LimitSettingDialog.DAYLIMIT) {
        _sliderTemp = 200;
      } else {
        _sliderTemp = 3000;
      }
    }
    return _sliderTemp;
  }

}