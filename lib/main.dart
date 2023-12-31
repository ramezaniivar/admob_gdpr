import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  //فقط در حالت تست
  //اگه در حال تست هستی، میتونی اطلاعات رو ریست کنی تا واسه دفعات بعدی هم دیالوگ نمایش داده بشه
  // ConsentInformation.instance.reset();

  //آخرین اطلاعات دریافت شده از کاربر
  //که چک کنی آیا نیاز به رضایت داره یا خیر
  final params = ConsentRequestParameters();
  ConsentInformation.instance.requestConsentInfoUpdate(
    params,
    () async {
      //اگه فرم در دسترس بود اون رو لود کن
      if (await ConsentInformation.instance.isConsentFormAvailable()) {
        loadForm();
      }
    },
    (FormError error) {
      log("gdpr error: ${error.message} with code: ${error.errorCode}");
    },
  );

  runApp(const MyApp());
}

void loadForm() {
  ConsentForm.loadConsentForm(
    (ConsentForm consentForm) async {
      //چک کردن وضعیت رضایت کاربر
      //ممکنه یکی از این 4 وضعیت باشه
      //1-unknown => وضعیت رضایت کاربر نامشخصه
      //2-required => رضایت مورد نیاز هست ولی هنوز گرفته نشده
      //3-notRequired => رضایت لازم نیست چون کاربر اروپایی نیست
      //4-obtained => انجام شد، اما نمیتونیم بفهمیم که کاربر رضایت داده یا نه
      var status = await ConsentInformation.instance.getConsentStatus();
      //اگه نیاز به رضایت بود، دیالوگ نمایش داده بشه
      if (status == ConsentStatus.required) {
        consentForm.show(
          (FormError? formError) {
            // اگه مشکلی هنگام نمایش دیالوگ به وجود اومد، دوباره لود بشه
            loadForm();
          },
        );
      }
    },
    (FormError formError) {
      log("${formError.message} with code: ${formError.errorCode}");
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}
