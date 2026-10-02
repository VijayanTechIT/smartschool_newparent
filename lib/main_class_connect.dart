import 'flavors.dart';

import 'main.dart' as runner;

Future<void> main() async{
  F.appFlavor = Flavor.classConnect;
  runner.main(flavor: "classConnect");
}