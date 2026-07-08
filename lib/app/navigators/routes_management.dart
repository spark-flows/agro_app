import 'package:get/get.dart';
import 'package:agro_app/app/widgets/show_full_scareen_image.dart';

import 'app_pages.dart';

abstract class RouteManagement {
  static void goToBottomScreen() => Get.offAllNamed<void>(Routes.bottomScreen);
  static void goToChatScreen(String? peerid, String? name, String chatId) =>
      Get.toNamed<void>(Routes.chatScreen, arguments: [peerid, name, chatId]);
  static void goToAuthScreen() => Get.offAllNamed<void>(Routes.authScreen);
  static void goToOtpScreen(String? mobile, String? key) =>
      Get.toNamed<void>(Routes.otpScreen, arguments: [mobile, key]);
  static void goToCreateGroupScreen() =>
      Get.toNamed<void>(Routes.createGroupScreen);
  static void goToCreateGroupTitleScreen() =>
      Get.toNamed<void>(Routes.createGroupTitleScreen);
  static void goToGroupChatMessageScreen(
    String? peerid,
    String? groupName,
    String? groupImage,
    String? groupId,
  ) => Get.toNamed<void>(
    Routes.groupChatMessageScreen,
    arguments: [peerid, groupName, groupImage, groupId],
  );
  static Future<dynamic> goToShareLocationScreen() =>
      Get.toNamed<dynamic>(Routes.shareLocationScreen) ?? Future.value(null);
  static void goToRegisterScreen() => Get.toNamed<void>(Routes.registerScreen);
  static Future<dynamic> goToUserListScreen({dynamic arguments}) =>
      Get.toNamed<dynamic>(Routes.userListScreen, arguments: arguments) ??
      Future.value(null);
  static Future<dynamic> goToShowFullScareenImage(
    String mediaUrl,
    String mediaType,
  ) =>
      Get.to<dynamic>(
        () => const ShowFullScareenImage(),
        arguments: [mediaUrl, mediaType],
      ) ??
      Future.value(null);

  // ─── New Screens ────────────────────────────────────────────────────────────
  static void goToCustomersScreen() =>
      Get.toNamed<void>(Routes.customersScreen);
  static void goToDistributorsScreen() =>
      Get.toNamed<void>(Routes.distributorsScreen);
  static void goToOrdersScreen() => Get.toNamed<void>(Routes.ordersScreen);
  static void goToCustomerOrdersScreen() =>
      Get.toNamed<void>(Routes.customerOrdersScreen);
  static void goToProductsScreen() => Get.toNamed<void>(Routes.productsScreen);
  static void goToProfileScreen() => Get.toNamed<void>(Routes.profileScreen);
  static void goToTasksScreen() => Get.toNamed<void>(Routes.tasksScreen);
  static void goToAttendanceScreen() =>
      Get.toNamed<void>(Routes.attendanceScreen);
  static void goToAttendanceForm() => Get.toNamed<void>(Routes.attendanceForm);
  static void goToSalaryScreen() => Get.toNamed<void>(Routes.salaryScreen);
  static void goToAddSalaryScreen() => Get.toNamed<void>(Routes.addSalaryScreen);
}
