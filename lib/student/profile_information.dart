import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_school_parent/student/devfile.dart';

import '../constants.dart';
import '../helper/studentapi.dart';
import '../student/profile_card.dart';
import 'package:flutter/material.dart';

import 'StudentModel.dart';

class StudentProfileInformation extends StatefulWidget {
  const StudentProfileInformation({super.key, required this.student});


  final StudentWhole student;

  @override
  State<StudentProfileInformation> createState() => _StudentProfileInformationState();
}

class _StudentProfileInformationState extends State<StudentProfileInformation> {
  String selectedCourses = '';
  File? _selectedImage;
  @override
  void initState(){
    super.initState();
  }


  Future<void> _getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // final imageCropper = ImageCropper();
      // final croppedFile = await imageCropper.cropImage(
      //   sourcePath: pickedFile.path,
      //   aspectRatio: CropAspectRatio(ratioX: 100, ratioY: 100),
      //
      //   uiSettings: [
      //     AndroidUiSettings(
      //         toolbarTitle: 'Cropper',
      //         toolbarColor: Colors.black,
      //         toolbarWidgetColor: Colors.white,
      //         initAspectRatio: CropAspectRatioPreset.original,
      //         lockAspectRatio: false),
      //     IOSUiSettings(
      //       title: 'Cropper',
      //     ),],
      // );
      //
      // if (croppedFile != null)  {

        _selectedImage = File(pickedFile.path);
        loadImageFile(_selectedImage!);
        final photoResponse = await StudentRecord().uploadPhoto(widget.student.studentId, _selectedImage!);
        if (photoResponse['status'] == "success") {
          setState(() async {
            final updatedStudent = widget.student.copyWithPhoto("web/uploads/StudentPhotos/${photoResponse['file']}");

            SharedPreferences prefs = await SharedPreferences.getInstance();

            prefs.setString('StudentData', json.encode(updatedStudent));
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>StudentHome(
                student: updatedStudent)),   (Route<dynamic> route) => false,);

          });
        }


       }
  }


  void loadImageFile(File file) async {
    if (_selectedImage != null) {
      setState(() {

      });
    }
  }
  Future<Uint8List> readFileAsUint8List(File file) async {
    return await file.readAsBytes();
  }
  String formatDob(String dob) {
    try {
      return DateFormat("dd-MM-yyyy").format(DateTime.parse(dob));
    } catch (_) {
      return dob; // Return as-is if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    var imagepath = Constants.imagePath;


    return Scaffold(
      backgroundColor: const Color(0xFF2d4c9c),
      appBar: AppBar(
        title: const Text("Profile",style:TextStyle(color:Colors.white)),
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios,color:Colors.white),
        ),
      ),
      body:Container(
        decoration: const BoxDecoration(
         color: Colors.white,
              borderRadius: BorderRadius.only(topRight: Radius.circular(50),topLeft: Radius.circular(50.0))),

        child:Padding(
          padding:const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top:10.0),
                  child: Row(
                    children:[
                      SizedBox(
                        child: Stack(
                          children: [
                            // _selectedImage != null
                            //     ? ClipOval(
                            //   clipBehavior: Clip.antiAliasWithSaveLayer,
                            //   child: Image.file(
                            //     _selectedImage!,
                            //     fit: BoxFit.contain,
                            //     color: Colors.transparent,
                            //     height: 70,
                            //     width: 110,
                            //   ),
                            // )
                            //     :
                        CircleAvatar(
                              radius: (widget.student.photo.isNotEmpty) ? 65 : 50,
                              backgroundColor: Colors.transparent,
                              child: (widget.student.photo.isNotEmpty)
                                  ? SizedBox(
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    ClipOval(
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      child:  Image(
                                      height:110,width:110,fit:BoxFit.cover,
                                        image: NetworkImage('$imagepath/${widget.student.photo}'),
                                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.key),
                                      ),
                                    ),

                                    Positioned(
                                      right: -25,
                                      bottom: 0,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            onPressed: _getImageFromGallery,
                                            icon: const Icon(Icons.edit, color: Color(0xFF2d4c9c)),
                                          ),
                                          const SizedBox(height: 15),
                                          IconButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                  ),
                                                  shadowColor: const Color(0xFF2d4c9c),
                                                  title: const Text('Remove Photo'),
                                                  titleTextStyle: const TextStyle(
                                                    fontSize: 18.0,
                                                    color: Colors.black,
                                                  ),
                                                  content: const Text(
                                                    'Are you sure to remove photo?',
                                                    style: TextStyle(fontSize: 16.0),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        StudentRecord()
                                                            .deletePhoto(widget.student.studentId)
                                                            .then((value) async{

                                                          final updatedStudent = widget.student.copyWithPhoto('');

                                                          SharedPreferences prefs = await SharedPreferences.getInstance();

                                                          prefs.setString('StudentData', json.encode(updatedStudent));
                                                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>StudentHome(
                                                              student: updatedStudent)),   (Route<dynamic> route) => false,);


                                                          setState(() {}); // refresh state
                                                        });
                                                      },
                                                      style: ButtonStyle(
                                                        shape: WidgetStateProperty.all(
                                                          RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(20.0),
                                                          ),
                                                        ),
                                                        backgroundColor: const WidgetStatePropertyAll<Color>(
                                                            Color(0xFF2d4c9c)),
                                                      ),
                                                      child: const Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 40.0),
                                                        child: Center(
                                                          child: Text('OK', style: TextStyle(color: Colors.white)),
                                                        ),
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      style: ButtonStyle(
                                                        shape: WidgetStateProperty.all(
                                                          RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(20.0),
                                                          ),
                                                        ),
                                                        backgroundColor: const WidgetStatePropertyAll<Color>(
                                                            Color(0xFF2d4c9c)),
                                                      ),
                                                      child: const Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 40.0),
                                                        child: Center(
                                                          child: Text('Cancel', style: TextStyle(color: Colors.white)),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.delete, color: Color(0xFF2d4c9c)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  : GestureDetector(
                                    onTap: (){
                                      _getImageFromGallery();
                                    },
                                    child: const Center(
                                                                    child: CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Color(0xFFeaeaea),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.person)
                                      ],
                                    ),
                                                                    ),
                                                                  ),
                                  ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(child: Container(
                                         
                                           decoration: BoxDecoration(
                                             color: Color(0xFFD3DCEA),
                                             borderRadius: BorderRadius.circular(10)
                                           ),
                                           padding: EdgeInsets.all(10),
                                           child: Column(
                                                                   mainAxisAlignment: MainAxisAlignment.start,
                                                                     crossAxisAlignment: CrossAxisAlignment.start,
                                                                     children: [
                                                                       Text(widget.student.name,style:const TextStyle(fontSize: 16)),
                                                                       Text(widget.student.studentId,style: const TextStyle(fontSize: 14),),
                                                                       Text("${widget.student.studyingGrade} - ${widget.student.studyingSection}",style: const TextStyle(fontSize: 12,color:Color(0xFF2d4c9c)),),
                                                                       Text(widget.student.address,style: const TextStyle(fontSize: 12),)
                                                                     ],
                                                                 ),
                                         )),
                      // SizedBox(
                      //    child:TextButton(onPressed:(){
                      //
                      //    },child:const Text('Edit',style: TextStyle(color:Color(0xFF2d4c9c)),))
                      // )
                    ]
                  ),
                ),
                const Divider(color: Colors.grey,),

                ProfileCard(
                  title: "Date Of Birth",
                  content: formatDob(widget.student.dob),
                ),


                // ProfileCard(title: "Date Of Joining", content: widget.student.dateOfJoining),
                ProfileCard(title: "Father Name", content: widget.student.fatherName),
                ProfileCard(title: "Phone Number", content: widget.student.phoneNumber),
                ProfileCard(title: "Whatsapp Number", content: widget.student.whatsappNo),
                Visibility(visible: (widget.student.email != ''),
                    child: ProfileCard(title: "Email Id", content: widget.student.email)) ,
                // Visibility(
                //     visible: (widget.student.emisNumber != ''),
                //     child: ProfileCard(title: "Emis Number", content: widget.student.emisNumber)) ,

                Visibility(
                    visible: (widget.student.studyingGrade != ''),
                    child: ProfileCard(title: "Studying Grade", content: widget.student.studyingGrade)) ,
                Visibility(
                    visible: (widget.student.studyingSection != ''),
                    child: ProfileCard(title: "Studying Section", content: widget.student.studyingSection)) ,

                Visibility(
                    visible: (widget.student.bloodGroup != ""),
                    child: ProfileCard(title: "Blood Group", content: widget.student.bloodGroup)) ,
                Visibility(
                    visible: (widget.student.aadharNo != ''),
                    child: ProfileCard(title: "Aadhar Number", content: widget.student.aadharNo)) ,

              ],
            ),
          ),
        )
      )
    );
  }
}
