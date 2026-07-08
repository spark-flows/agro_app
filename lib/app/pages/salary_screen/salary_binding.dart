import 'package:agro_app/app/pages/salary_screen/salary_page.dart';
import 'package:agro_app/app/pages/salary_screen/salary_presenter.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:get/get.dart';

class SalaryBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SalaryController>(
      () => SalaryController(
        Get.put(
          SalaryPresenter(Get.put(SalaryUsecases(Get.find()), permanent: true)),
        ),
      ),
    );
  }
}
