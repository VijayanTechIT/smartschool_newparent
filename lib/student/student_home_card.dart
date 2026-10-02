import 'package:flutter/material.dart';

class StudentHomeCard extends StatelessWidget {
  const StudentHomeCard({super.key,this.child,required this.text,required this.image,
  required this.bottomText,this.text3,required this.bottomText2,required this.btColor,required this.valueText,required this.height,required this.width});
  final Widget image;
  final Color btColor;
  final double height;
  final double width;
  final String valueText;
  final String bottomText2;
  final String? text3;
  final String bottomText;
  final String text;
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height:height,width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10)
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:EdgeInsets.only(left:5),
                    child:Text(
                     text,style: TextStyle(fontSize:15,),
                  ),),

                  SizedBox(height: 5,),
                  Row(
                    children: [
                      image,
                      Padding(
                        padding: const EdgeInsets.only(left:5.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(valueText,style: TextStyle(fontSize:18 ),),
                            Row(
                              children: [
                                Text(bottomText2,style:TextStyle(color:Colors.black,
                                    fontSize: 13,fontWeight: FontWeight.bold)),
                                Visibility(
                                  visible: text3 != null && text3!.isNotEmpty,
                                  child: Text(
                                    " $text3",
                                    style: TextStyle(
                                      color: btColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )

                              ],
                            ),
                            Text(bottomText,style:TextStyle(fontSize: 14)),

                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),

            ],
          ),
        )
      ),
    );
  }
}
