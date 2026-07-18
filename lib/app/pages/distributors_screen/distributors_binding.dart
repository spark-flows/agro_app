import 'package:agro_app/app/pages/distributors_screen/distributors_controller.dart';
import 'package:get/get.dart';

class DistributorsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DistributorsController>(
      () => DistributorsController(),
      fenix: true,
    );
  }
}
