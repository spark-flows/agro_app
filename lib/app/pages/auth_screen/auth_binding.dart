import 'package:get/get.dart';
import 'package:agro_app/app/app.dart';
import 'package:agro_app/domain/domain.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(
      () => AuthController(
        Get.put(
          AuthPresenter(Get.put(AuthUsecases(Get.find()), permanent: true)),
        ),
      ),
    );
  }
}
