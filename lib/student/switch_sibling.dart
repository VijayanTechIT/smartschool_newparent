import 'package:flutter/material.dart';
import 'package:smart_school_parent/helper/studentapi.dart';

import '../models/siblings_model.dart';
import 'devfile.dart';

class SwitchSibling extends StatefulWidget {
  const SwitchSibling({super.key,required this.siblings,
    required this.schoolCode,
    required this.studentId});

  final String studentId;

  final String schoolCode;

  final List<SiblingModel> siblings;
  @override
  State<SwitchSibling> createState() => _SwitchSiblingState();
}

class _SwitchSiblingState extends State<SwitchSibling> {
  String isActive = "";

  @override
  void initState() {

    isActive = widget.studentId.toUpperCase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF2d4c9c),
          title: const Text(
              "Switch Sibling", style: TextStyle(color: Colors.white)),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.siblings.length,
                itemBuilder: (context, index) {
                  var sibling = widget.siblings[index];

                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Card(
                      elevation: 1,
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(sibling.studentId),
                        subtitle: Text(sibling.name),
                        trailing: (widget.siblings[index].studentId.toUpperCase() == isActive)
                            ?
                        CircleAvatar(radius: 15,
                          backgroundColor: Color(0xFF2d4c9c),
                          child: Icon(Icons.check, color: Colors.white,),
                        )
                            : SizedBox.shrink()
                        ,
                        onTap: () {
                          setState(() {
                            isActive = sibling.studentId;
                          });
                          StudentRecord().signinstudent(
                              sibling.dob, sibling.studentId,widget.schoolCode).then((value) {

                            if (value != null) {

                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  StudentHome(student: value)),
                                              (Route<
                                              dynamic> route) => false, // This condition removes all previous routes
                                        );

                            } else {
                              showDialog(context: context, builder: (context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10.0)),
                                  shadowColor: const Color(0xFF2d4c9c),
                                  title: const Text('Alert'),
                                  titleTextStyle: const TextStyle(
                                      fontSize: 18.0, color: Colors.black),
                                  content: const Text(
                                    'Check student id status ',
                                    style: TextStyle(
                                        fontSize: 16.0, color: Colors.black),),
                                  actions: [
                                    TextButton(onPressed: () {
                                      Navigator.pop(context);
                                    },
                                        style: ButtonStyle(
                                          shape: WidgetStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius: BorderRadius
                                                  .circular(20.0),
                                            ),
                                          ), alignment: Alignment.bottomRight,
                                          backgroundColor: const WidgetStatePropertyAll<
                                              Color>(Color(0xFF2d4c9c)),
                                        ), child: const Padding(
                                          padding: EdgeInsets.only(
                                              left: 20.0, right: 20.0),
                                          child: Center(child: Text('OK',
                                            style: TextStyle(
                                                color: Colors.white),)),
                                        )),
                                  ],
                                );
                              });
                            }
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        )
    );
  }
}
