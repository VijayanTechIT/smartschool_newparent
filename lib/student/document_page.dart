import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:smart_school_parent/student/StudentModel.dart';
import 'package:smart_school_parent/student/studentapi.dart';
import 'package:smart_school_parent/student/upload_doc_page.dart';
import 'package:uuid/uuid.dart';

import '../constants.dart';
import '../firebaseApi.dart';
import '../helper/studentapi.dart';
import '../utilis/loader.dart';

class DocumentPage extends StatefulWidget {
  const DocumentPage({super.key,required this.student,required this.documents});

  final documents;

  final StudentWhole student;

  @override
  State<DocumentPage> createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {


  /// Downloads a file from the given URL and saves it to the app's internal documents directory.
  ///
  /// A unique file name is generated based on a UUID and the file extension from the URL.
  ///
  /// [url]: The URL of the file to download.
  /// Returns a Future<File> representing the downloaded file, or an empty File
  /// if an error occurs.
  Future<File> _downloadFile(String url,String name) async {
    print("downloadFileToInternalStorage called for URL: $url");
    try {
      // Use http.Client for simpler and more modern HTTP requests
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Get the application's documents directory
        final directory = await getApplicationDocumentsDirectory();

        // Extract file extension from the URL
        String fileExtension = '';
        final uri = Uri.parse(url);
        final pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty) {
          final lastSegment = pathSegments.last;
          if (lastSegment.contains('.')) {
            fileExtension = lastSegment.split('.').last;
          }
        }

        // Generate a unique file name using UUID
        final uuid = Uuid();
        final uniqueFileName = '${uuid.v4()}${fileExtension.isNotEmpty ? '.$fileExtension' : ''}';

        final filePath = '${directory.path}/$uniqueFileName';
        final file = File(filePath);

        // Write the bytes to the file
        await file.writeAsBytes(response.bodyBytes);

        if (await file.exists()) {
          // Show notification
          Firebaseapi().showLocalNotificationLocal(
            'Download Complete',
            'File saved to documents',
            filePath,
          );

          return file;
        } else {
          throw Exception("File not saved to internal storage.");
        }
      } else {
        throw Exception('HTTP request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print("Error during file download: $error");
      return File(''); // Return an empty File on error
    }
  }


  Future<void> _scanFile(String filePath) async {
    try {
      var platform = MethodChannel('com.example.app/filescanner');
      await platform.invokeMethod('scanFile', {"path": filePath});
    } catch (e) {
    }
  }

  @override
  void initState(){
    super.initState();
    documents = widget.documents;
  }

  List<dynamic>? documents = [];
 void fetchData(){
   StudentApi().getDocumentsByStudentId(widget.student.studentId,
       widget.student.schoolCode).then((value) async {

     if(value == null){}else {
       setState(() {
         documents = value;
       });
       // Assign null if value is null, otherwise assign the value

     }
 });
 }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double maxWidth = 600.0;
    double effectiveWidth = screenWidth > maxWidth ? maxWidth : screenWidth;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2d4c9c),
        centerTitle: true,
        title: const Text(
          "Documents",
          style: TextStyle(fontSize: 20.0, color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: documents == null
            ? const Center(child: Loader())
            : documents!.isEmpty
            ? const Center(child: Text('No documents found.'))
            : ListView.builder(
          itemCount: documents!.length,
          itemBuilder: (context, index) {
            final doc = documents![index];
            final category = doc['category'] ?? '';

            final fileName = doc['file_location'] ?? '';
            final parts = fileName.split('_');
            final lastTwo = parts.length >= 2 ? '${parts[parts.length - 2]}_${parts.last}' : fileName;

            final fileDescription = doc['file_description'] ?? '';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Text(category, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(lastTwo),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.download, color: Color(0xFF2d4c9c)),
                      onPressed: () {
                        final fileUrl = "${Constants.url}/${doc['file_location']}";
                        _downloadFile(fileUrl, "Smart School Parent");
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors. redAccent),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Delete Confirmation"),
                            content: const Text("Are you sure you want to delete this file?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  StudentRecord().deleteStudentDoc(widget.student.studentId, doc['Id'].toString());
                                  documents!.removeAt(index);
                                  setState(() {});
                                  Navigator.pop(context, true);
                                },
                                child: const Text("Delete", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: SizedBox(
        width: effectiveWidth * 0.6,
        height: 45,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2d4c9c),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.upload_file, color: Colors.white),
          label: const Text('Upload Document', style: TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => UploadDocument(student: widget.student)),
            ).then((value){
              fetchData();
            });
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

}
