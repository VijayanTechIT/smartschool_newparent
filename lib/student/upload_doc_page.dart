import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../student/devfile.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../student/StudentModel.dart';
import '../student/studentapi.dart';

class UploadDocument extends StatefulWidget {
  const UploadDocument({super.key,required this.student});

  final StudentWhole student;
  @override
  State<UploadDocument> createState() => _UploadDocumentState();
}

class _UploadDocumentState extends State<UploadDocument> {

  File? documentFile;
  String fileSizeInKB = '0.0';
  bool isButtonok = true;

  void loaddocFile(File file) async {
    int fileLengthInBytes = await file.length();
    fileSizeInKB = (fileLengthInBytes / 1024).toStringAsFixed(0);
    // print('File size: ${fileSizeInKB.toStringAsFixed(0)} KB');
    setState(() {

    });
    }

  final TextEditingController descController = TextEditingController();


  Future<void> pickFile(String studentId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );

    if (result != null) {
      File originalFile = File(result.files.single.path!);
      int fileLengthInBytes = await originalFile.length();

      // Max size = 10MB = 10 * 1024 * 1024 bytes
      if (fileLengthInBytes > 10 * 1024 * 1024) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              shadowColor: const Color(0xFF2d4c9c),
              title: const Text('Alert'),
              titleTextStyle: const TextStyle(fontSize: 18.0, color: Colors.black),
              content: Text('File too large. Max allowed size is 10 MB.', style: TextStyle(fontSize: 16.0, color: Colors.black)),
              actions: [
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
                    alignment: Alignment.bottomRight,
                    backgroundColor: WidgetStateProperty.all<Color>(const Color(0xFF2d4c9c)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Center(child: Text('OK', style: TextStyle(color: Colors.white))),
                  ),
                ),
              ],
            );
          },
        );

        return;
      }

      // ✅ Rename file: studentId_random.extension
      String extension = p.extension(originalFile.path);
      String randomPart = const Uuid().v4().substring(0, 6);
      String newFileName = "${studentId}_$randomPart$extension";

      Directory appDir = await getTemporaryDirectory();
      String newPath = p.join(appDir.path, newFileName);
      File renamedFile = await originalFile.copy(newPath);

      // Save or upload renamedFile
      documentFile = renamedFile;
      loaddocFile(renamedFile);
    } else {
      // User cancelled
    }
  }

  String? selectedCategory;
  final TextEditingController titleController = TextEditingController();
  final List<String> docCategories = [
    'Aadhar',
    'Community Certificate',
    'Birth Certificate',
    'Others',
  ];
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document',style: TextStyle(color:Colors.white),),
      leading: IconButton(onPressed: (){
        Navigator.pop(context);
      }, icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: InputDecoration(
                        labelText: "Document Category",
                        prefixIcon: const Icon(Icons.folder),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: docCategories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    if (selectedCategory == 'Others') ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descController,
                        style: const TextStyle(fontSize: 16.0),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                          labelText: "File Description",
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    ElevatedButton.icon(
                      onPressed: (){pickFile(widget.student.studentId);},
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Choose File'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color(0xFF2d4c9c),
                        backgroundColor: Colors.grey[100],
                        side: const BorderSide(color: Color(0xFF2d4c9c)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    if (documentFile != null) ...[
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.insert_drive_file, color: Colors.grey),
                        title: Text(path.basename(documentFile!.path),
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text("Size: $fileSizeInKB KB"),
                      ),
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: ElevatedButton.icon(
                  onPressed: isButtonok ? _onUploadPressed : null,
                  icon: isButtonok
                      ? const Icon(Icons.cloud_upload,color:Colors.white)
                      : const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                  label: Text(
                    isButtonok ? 'Upload' : 'Processing...',
                    style: const TextStyle(fontSize: 18,color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2d4c9c),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                "Accepted file types: PDF, JPG, PNG \n• Max size: 10MB",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
          ],
        ),
      ),

    );
  }

  void _onUploadPressed() async {
    setState(() => isButtonok = false);

    if (selectedCategory == null) {
      _showAlert('Select Category to insert document');
      setState(() => isButtonok = true);
      return;
    }

    if (selectedCategory == 'Others' && descController.text.trim().isEmpty) {
      _showAlert('Enter Title name to insert document');
      setState(() => isButtonok = true);
      return;
    }

    if (documentFile == null) {
      _showAlert('Add documents to proceed!');
      setState(() => isButtonok = true);
      return;
    }

    String categoryName  = selectedCategory == 'Others' ? descController.text: selectedCategory ?? '';

    // Proceed with upload
   String response =  await StudentApi().insertStudentDoc(
      categoryName,
      widget.student.studentId,
      widget.student.schoolCode,
      descController.text,
      documentFile!,
    );
 if(response == 'success'){
   showDialog(
     context: context,
     builder: (_) => AlertDialog(
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
       title: const Text('Success'),
       content: Text("Document uploaded successfully"),
       actions: [
         TextButton(
           onPressed: (){
             // Navigator.pushReplacement(context, MaterialPageRoute(
             //   builder: (context) => StudentHome(student: widget.student),
             // ));
             Navigator.pop(context);
             Navigator.pop(context);
             },
           style: TextButton.styleFrom(
             backgroundColor: const Color(0xFF2d4c9c),
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
           ),
           child: const Text('OK', style: TextStyle(color: Colors.white)),
         ),
       ],
     ),
   );
 }else{}
    // Navigator.pushReplacement(context, MaterialPageRoute(
    //   builder: (context) => StudentHome(student: widget.student),
    // ));
  }


  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: const Text('Alert'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF2d4c9c),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }


  Future <Map<String, dynamic>>usermap () async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userRecord = prefs.getString('userData');
    return jsonDecode(userRecord!);
  }
}
