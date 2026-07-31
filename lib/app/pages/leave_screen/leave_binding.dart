import 'package:agro_app/app/pages/leave_screen/leave_controller.dart';
import 'package:get/get.dart';

class LeaveBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LeaveController>(() => LeaveController());
  }
}
