import 'package:agro_app/app/pages/ledgers_screen/ledgers_controller.dart';
import 'package:get/get.dart';

class LedgersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LedgersController>(() => LedgersController());
  }
}
