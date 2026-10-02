import 'package:url_launcher/url_launcher.dart';

class CallUtils {
  // Function to make a phone call
  static Future<void> makePhoneCall() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: '9840962424',
    );

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      // Optional: handle the error when the URL can't be launched
      print("Could not launch phone call to 9840962424");
    }
  }


  // Function to open WhatsApp with a specific phone number and message
  void sendWhatsAppMessage(String message,String schoolName, String phoneNumber) async {
    // WhatsApp API URL format
    final String url = "https://api.whatsapp.com/send/?phone=919840962424&text=Hello%2C+we+are+looking+for+your+support+in+$schoolName+Parent+App+%21%21&type=phone_number&app_absent=0";

    // Check if the URL can be launched
    if (await launchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

}




