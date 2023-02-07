import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dissonance_survey_4/main/main_page_binding.dart';
import 'package:dissonance_survey_4/admin/admin_page_binding.dart';
import 'admin/admin_page.dart';
import 'main/main_page.dart';


class App extends StatelessWidget {
  // 라우트 기능
  // webtoon.naver.com/10
  // webtoon.naver.com/100
  // cafe.naver.com
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: '/main',
      getPages: [
        GetPage(name: '/main', page: () => MainPage(), binding: MainPageBinding()),
        GetPage(name: '/admin', page: () => AdminPage(), binding: AdminPageBinding()),
      ],
    );
  }
}
