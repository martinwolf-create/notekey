import 'package:url_launcher/url_launcher.dart';

Future<void> openNoteKeyWebsite() async {
  final Uri url = Uri.parse("https://notekey.de");
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    throw "Could not launch $url";
  }
}
