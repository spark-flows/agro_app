import 'package:agro_app/app/pages/expense_screen/expense_controller.dart';
import 'package:get/get.dart';

class ExpenseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExpenseController>(() => ExpenseController());
  }
}
