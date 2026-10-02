

/// Flavor enums for release stage
///
enum Flavor{
  /// js academy
  jsAcademy,
  /// smart school
  smartSchool,
  ///kamadhenu
  shreeKamadhenuSchool,
  ///ssv school sivagiri
  ssv,
  /// my school
  classConnect,
  /// komarasamy gounder mhss
  kg,
  /// karunya vidya bhavan
  kv,
  ///Mrs school
  mrs
}


/// class F to define the flavors
///
class F{
  /// the app flavor for which release is to be done
  static Flavor? appFlavor;

  /// name string of the flavor
  static String get name => appFlavor?.name ?? "";

  /// get title for the flavor name
  static String get title{
    switch (appFlavor){
      case Flavor.jsAcademy:
        return 'Jai Shri Ram Parent';
      case Flavor.smartSchool:
        return 'Smart School Parent';
      case Flavor.shreeKamadhenuSchool:
        return 'Kamadhenu MHSS Parent';
      case Flavor.kv:
        return 'Karunya Vidya Bhavan';
      case Flavor.ssv:
        return 'SSV Sivagiri';
      case Flavor.kg:
        return 'Komarasamy Gounder MHSS';
      case Flavor.classConnect:
        return 'Class Connect';
      case Flavor.mrs:
        return 'MRS Matric School';
      default:
        return 'title';
    }
  }
}