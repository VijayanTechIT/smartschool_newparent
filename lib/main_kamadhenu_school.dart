import 'flavors.dart';

import 'main.dart' as runner;

Future<void> main() async{
  F.appFlavor = Flavor.shreeKamadhenuSchool;
  runner.main(flavor: "Kamadhenu MHSS");
}