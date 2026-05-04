import 'package:get/get.dart';
import 'package:agro_app/app/pages/customers_screen/customers_controller.dart';

class CustomersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomersController>(() => CustomersController());
  }
}
