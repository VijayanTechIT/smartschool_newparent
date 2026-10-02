class AppConfig {
  static String flavor = "default";  // Default value
  static String appName = "Default";
  static String schoolCode = "KT";
  static String apiKey = "";
  static String secretKey = "";

  static void setFlavor(String selectedFlavor) {
    flavor = selectedFlavor;

    if (flavor == "jsAcademy") {
      appName = "Jai ShriRam Parent";
      schoolCode = "JS";
    } else if (flavor == "shreeKamadhenuSchool") {
      appName = "Shree Kamadhenu School";
      schoolCode = "KT";
    }else if (flavor == "ssv") {
      appName = "SSV Sivagiri";
      schoolCode = "SS";
    }else if (flavor == "classConnect") {
      appName = "Class Connect";
      schoolCode = "MY";
      apiKey = "112706cf1f903b06d8f001fbf4607211";
      secretKey ="cfsk_ma_test_fe7a73e69c70752619165c66518d5ec2_3a6b05fc";
    }else if (flavor == "kg") {
      appName = "KG Matric Hr. Sec. School";
      schoolCode = "KG";
    }
    else if (flavor == "smartSchool") {
      appName = "Smart School Parent";
      schoolCode = "MY";
    }
    else if (flavor == "kv") {
      appName = "Karunya Vidya Bhavan";
      schoolCode = "KV";
    }
    else if (flavor == "mrs") {
      appName = "MRS";
      schoolCode = "MRS";
    }
  }
}
