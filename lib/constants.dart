// class Constants{
//
//
//
//   static const url = "https://smartschool.vijayantech.com";
//
//   static const imagepath = "$url";
//
//   // static const url ="http://192.168.1.6/smart_school";
//
//
// }

class Constants {
  static late String url;
  static late String imagePath;
  static const appVersion = '4.1.6';

  static void init(String flavor) {
    switch (flavor) {
      case "classConnect":
        url = "https://classConnect.vijayantech.com";
        break;
      case "smartSchool":
        url = "https://smartschool.vijayantech.com";
        break;
      case "shreeKamadhenuSchool":
        url = "https://smartschool.vijayantech.com";
        break;
      case "ssv":
        url = "https://smartschool.vijayantech.com";
        break;
      case "mrs":
        url = "https://smartschool.vijayantech.com";
        break;
      case "kg":
        url = "https://smartschool.vijayantech.com";
        break;
      case "kv":
        url = "https://smartschool.vijayantech.com";
        break;
      default:
        url = "https://smartschool.vijayantech.com";
        break;
    }

    imagePath = url;
  }
}
