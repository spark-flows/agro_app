import 'package:get/get.dart';
import 'package:agro_app/app/navigators/routes_management.dart';

class HomeController extends GetxController {
  void goToCustomers() => RouteManagement.goToCustomersScreen();
  void goToOrders() => RouteManagement.goToOrdersScreen();
  void goToProfile() => RouteManagement.goToProfileScreen();
}
