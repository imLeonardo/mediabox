import 'dart:io';

import 'package:get/get.dart';
import 'package:miru_app/router/router.dart';

class RouterUtils {
  static pop() {
    if (Platform.isAndroid) {
      return Get.back();
    }
    return router.pop();
  }
}
