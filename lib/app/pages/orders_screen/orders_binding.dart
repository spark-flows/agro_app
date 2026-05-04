import 'package:get/get.dart';
import 'package:agro_app/app/pages/orders_screen/orders_controller.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrdersController>(() => OrdersController());
  }
}
