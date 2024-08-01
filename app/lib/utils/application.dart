// ignore_for_file: use_build_context_synchronously
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:mediabox/utils/i18n.dart';
import 'package:mediabox/utils/request.dart';
import 'package:mediabox/utils/router.dart';
import 'package:mediabox/views/widgets/button.dart';
import 'package:mediabox/views/widgets/messenger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

late PackageInfo packageInfo;
late AndroidDeviceInfo androidDeviceInfo;
late WindowsDeviceInfo windowsDeviceInfo;
late LinuxDeviceInfo linuxDeviceInfo;

class ApplicationUtils {
  static Future ensureInitialized() async {
    packageInfo = await PackageInfo.fromPlatform();
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      androidDeviceInfo = await deviceInfo.androidInfo;
      return packageInfo;
    }
    if (Platform.isLinux) {
      linuxDeviceInfo = await deviceInfo.linuxInfo;
      return packageInfo;
    }
    if (Platform.isWindows) {
      windowsDeviceInfo = await deviceInfo.windowsInfo;
    }
    return packageInfo;
  }

  static checkUpdate(BuildContext context, {bool showSnackbar = false}) async {
    try {
      const url =
          "https://api.github.com/repos/miru-project/miru-app/releases/latest";
      final res = await dio.get(url);
      final remoteVersion =
          (res.data["tag_name"] as String).replaceFirst('v', '');
      debugPrint('remoteVersion: $remoteVersion');
      if (packageInfo.version != remoteVersion) {
        if (Platform.isAndroid) {
          Get.to(
            Scaffold(
              appBar: AppBar(
                title: Text(
                  FlutterI18n.translate(
                    context,
                    'upgrade.new-version',
                    translationParams: {
                      'version': remoteVersion,
                    },
                  ),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(child: Markdown(data: res.data['body'])),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: PlatformFilledButton(
                        onPressed: () {
                          RouterUtils.pop();
                          launchUrl(
                            Uri.parse(res.data['html_url']),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        child: Text('upgrade.download'.i18n),
                      ),
                    )
                  ],
                ),
              ),
            ),
            transition: Transition.rightToLeftWithFade,
          );
          return;
        }

        showPlatformDialog(
          context: context,
          title: FlutterI18n.translate(
            context,
            'upgrade.new-version',
            translationParams: {
              'version': remoteVersion,
            },
          ),
          content: Markdown(
            shrinkWrap: true,
            data: res.data['body'],
          ),
          actions: [
            PlatformTextButton(
              onPressed: () {
                RouterUtils.pop();
              },
              child: Text('upgrade.not-now'.i18n),
            ),
            PlatformFilledButton(
              onPressed: () {
                RouterUtils.pop();
                launchUrl(
                  Uri.parse(res.data['html_url']),
                  mode: LaunchMode.externalApplication,
                );
              },
              child: Text('upgrade.download'.i18n),
            )
          ],
        );
      } else {
        if (!showSnackbar) {
          return;
        }
        showPlatformSnackbar(
          context: context,
          title: 'upgrade.check-update'.i18n,
          content: "upgrade.no-update".i18n,
        );
      }
    } catch (e) {
      if (!showSnackbar) {
        return;
      }
      showPlatformSnackbar(
        context: context,
        title: 'upgrade.check-update'.i18n,
        content: 'upgrade.error'.i18n,
      );
    }
  }
}
