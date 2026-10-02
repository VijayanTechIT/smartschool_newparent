import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key,required this.title,required this.content});

  final String title;
  final String content;
  @override
  Widget build(BuildContext context) {
    return Column(
      children:[
        Align(alignment: Alignment.topLeft,
            child:Text(title)),
        Padding(
          padding: const EdgeInsets.only(top:8.0,bottom: 15),
          child: Container(
              width:double.infinity,
              decoration: BoxDecoration(color: Color(0xFFCBCBCB),
              borderRadius: BorderRadius.circular(5)),
              child:Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(content),
              )
          ),
        )

      ]
    );
  }
}
