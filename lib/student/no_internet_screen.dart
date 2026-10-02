import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../internet_conn/internet_connection_bloc.dart';

class NoInternetScreen extends StatefulWidget {
  final bool shouldPopOnReconnect;
  const NoInternetScreen({super.key,required this.shouldPopOnReconnect});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {

  @override
  void initState() {
    super.initState();

    if (widget.shouldPopOnReconnect) {
      Future.delayed(Duration.zero, () {
        context.read<InternetConnectionBloc>().stream.listen((state) {
          if (state is InternetConnected) {
            Navigator.pop(context);
          }
        });
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text('Smart School',

          style: const TextStyle(fontSize:16,color:Colors.white),),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: AssetImage("images/noInternet.png"),
              height: 70,width: 70,
            ),
            SizedBox(height: 25,),
            Text("Oops !!",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2d4c9c)
              ),
            ),
            SizedBox(height: 20,),
            Text("No Internet Connection found\nPlease check your Internet Settings",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600
              ),
            ),
          ],
        ),
      ),
    );
  }
}
