import 'package:agro_app/domain/domain.dart';
import 'package:agro_app/domain/models/auth_model.dart';
import 'package:agro_app/domain/models/user_register_model.dart';

class AuthPresenter {
  AuthPresenter(this.authUsecases);

  final AuthUsecases authUsecases;

  Future<LoginModel?> loginApi({
    required String userName,
    required String password,
    required String fcmToken,
    bool isLoading = false,
  }) =>
      authUsecases.loginApi(
        userName: userName,
        password: password,
        fcmToken: fcmToken,
        isLoading: isLoading,
      );
}
