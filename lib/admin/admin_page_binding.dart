import 'package:get/get.dart';

import 'admin_page_controller.dart';
import 'admin_page_model.dart';

class AdminPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AdminPageController>(
      AdminPageController(
        model: AdminPageModel.empty().copyWith(adminsetting: {}),
      ),
    );
  }
}
