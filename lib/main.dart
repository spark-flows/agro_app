import 'package:agro_app/app/app.dart';
import 'package:agro_app/data/data.dart';
import 'package:agro_app/device/device.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:upgrader/upgrader.dart';
import 'firebase_options.dart';

// Admin
// admin@agro.com
// PY@002025

// Raj
// aayush@gmail.com
// 12345678

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseApi.initilizeNotification();
  await initServices();
  await Upgrader.clearSavedSettings();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

Future<void> initServices() async {
  await Hive.initFlutter();

  Get.put(
    Repository(
      Get.put(DeviceRepository(), permanent: true),
      Get.put(
        DataRepository(Get.put(ConnectHelper(), permanent: true)),
        permanent: true,
      ),
    ),
  );

  /// Services
  await Get.putAsync(() => CommonService().init());
  await Get.putAsync(() => DbService().init());
}

class DbService extends GetxService {
  Future<DbService> init() async {
    await Get.find<DeviceRepository>().init();
    return this;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarColor: ColorsValue.primary,
      ),
    );

    final Upgrader upgrader = Upgrader(debugLogging: true);

    return ScreenUtilInit(
      minTextAdapt: true,
      designSize: const Size(375, 745),
      builder: (_, child) => UpgradeAlert(
        dialogStyle: UpgradeDialogStyle.material,
        upgrader: upgrader,
        child: GetMaterialApp(
          locale: const Locale('en'),
          debugShowCheckedModeBanner: false,
          title: StringConstants.appName,
          theme: themeData(context),
          darkTheme: darkThemeData(context),
          themeMode: ThemeMode.light,
          getPages: AppPages.pages,
          initialRoute: Routes.splashScreen,
          translations: TranslationsFile(),
          navigatorKey: Get.key,
          enableLog: true,
        ),
      ),
    );
  }
}
