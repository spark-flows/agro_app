import 'package:get/get.dart';
import 'package:agro_app/app/pages/auth_screen/screens/register_screen.dart';
import 'package:agro_app/app/pages/pages.dart';
import 'package:agro_app/app/pages/profile_screen/profile_binding.dart';
import 'package:agro_app/app/pages/profile_screen/profile_screen.dart';

part 'app_routes.dart';

class AppPages {
  static var transitionDuration = const Duration(milliseconds: 300);

  static const initial = _Paths.splashScreen;
  static final pages = <GetPage>[
    GetPage<SplashScreen>(
      name: _Paths.splashScreen,
      transitionDuration: transitionDuration,
      page: SplashScreen.new,
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage<RegisterScreen>(
      name: _Paths.registerScreen,
      transitionDuration: transitionDuration,
      page: RegisterScreen.new,
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage<AuthScreen>(
      name: _Paths.authScreen,
      transitionDuration: transitionDuration,
      page: AuthScreen.new,
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage<OtpScreen>(
      name: _Paths.otpScreen,
      transitionDuration: transitionDuration,
      page: OtpScreen.new,
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage<HomeScreen>(
      name: _Paths.bottomScreen,
      transitionDuration: transitionDuration,
      page: HomeScreen.new,
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage<CustomersScreen>(
      name: _Paths.customersScreen,
      transitionDuration: transitionDuration,
      page: CustomersScreen.new,
      binding: CustomersBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<DistributorsScreen>(
      name: _Paths.distributorsScreen,
      transitionDuration: transitionDuration,
      page: DistributorsScreen.new,
      binding: DistributorsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<DistributorFormPage>(
      name: _Paths.distributorForm,
      transitionDuration: transitionDuration,
      page: DistributorFormPage.new,
      binding: DistributorsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<ProductsScreen>(
      name: _Paths.productsScreen,
      transitionDuration: transitionDuration,
      page: ProductsScreen.new,
      binding: ProductsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<ProductFormPage>(
      name: _Paths.productForm,
      transitionDuration: transitionDuration,
      page: ProductFormPage.new,
      binding: ProductsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<OrdersScreen>(
      name: _Paths.ordersScreen,
      transitionDuration: transitionDuration,
      page: OrdersScreen.new,
      binding: OrdersBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<CustomerOrdersScreen>(
      name: _Paths.customerOrdersScreen,
      transitionDuration: transitionDuration,
      page: CustomerOrdersScreen.new,
      binding: CustomerOrdersBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<UsersScreen>(
      name: _Paths.userListScreen,
      transitionDuration: transitionDuration,
      page: UsersScreen.new,
      binding: UsersBinding(),
      transition: Transition.rightToLeft,
    ),

    GetPage<ProfileScreen>(
      name: _Paths.profileScreen,
      transitionDuration: transitionDuration,
      page: ProfileScreen.new,
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<TasksScreen>(
      name: _Paths.tasksScreen,
      transitionDuration: transitionDuration,
      page: TasksScreen.new,
      binding: TasksBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<TaskFormPage>(
      name: _Paths.taskForm,
      transitionDuration: transitionDuration,
      page: TaskFormPage.new,
      binding: TasksBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<AttendanceScreen>(
      name: _Paths.attendanceScreen,
      transitionDuration: transitionDuration,
      page: AttendanceScreen.new,
      binding: AttendanceBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<AttendanceFormPage>(
      name: _Paths.attendanceForm,
      transitionDuration: transitionDuration,
      page: AttendanceFormPage.new,
      binding: AttendanceBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<SalaryScreen>(
      name: _Paths.salaryScreen,
      transitionDuration: transitionDuration,
      page: SalaryScreen.new,
      binding: SalaryBindings(),
      transition: Transition.rightToLeft,
    ),
    GetPage<AddSalaryScreen>(
      name: _Paths.addSalaryScreen,
      transitionDuration: transitionDuration,
      page: AddSalaryScreen.new,
      binding: SalaryBindings(),
      transition: Transition.rightToLeft,
    ),
  ];
}
