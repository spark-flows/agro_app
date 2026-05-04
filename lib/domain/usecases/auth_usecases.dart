import 'package:agro_app/domain/models/auth_model.dart';
import 'package:agro_app/domain/models/user_register_model.dart';
import 'package:agro_app/domain/repositories/repository.dart';

class AuthUsecases {
  AuthUsecases(this.repository);

  final Repository repository;

  Future<LoginModel?> loginApi({
    required String userName,
    required String password,
    required String fcmToken,
    bool isLoading = false,
  }) =>
      repository.loginApi(
        userName: userName,
        password: password,
        fcmToken: fcmToken,
        isLoading: isLoading,
      );
}
