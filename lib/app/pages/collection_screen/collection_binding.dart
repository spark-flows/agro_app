import 'package:agro_app/app/pages/collection_screen/collection_controller.dart';
import 'package:get/get.dart';

class CollectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CollectionController>(() => CollectionController());
  }
}
