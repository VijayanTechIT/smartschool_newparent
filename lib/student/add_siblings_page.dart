import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_school_parent/student/studentapi.dart';

class AddSiblingsPage extends StatefulWidget {
  const AddSiblingsPage({super.key});

  @override
  State<AddSiblingsPage> createState() => _AddSiblingsPageState();
}

class _AddSiblingsPageState extends State<AddSiblingsPage> {
  final TextEditingController _studentIdController = TextEditingController();
  bool passwordVisible = false;
  String? selectedRelationship;
  final List<String> relationships = ['Brother', 'Sister', 'Cousin'];

  void submitSibling()async {

    if (_studentIdController.text.isEmpty || dobController.text.isEmpty || selectedRelationship == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }
    setState((){
      isLoading = true;
    });
    // Extract day, month, year
    int day = int.parse(dobController.text.substring(0, 2));
    int month = int.parse(dobController.text.substring(2, 4));
    int year = int.parse(dobController.text.substring(4, 8));

    // Create DateTime object
    DateTime dateTime = DateTime(year, month, day);

    // Format to yyyy-MM-dd
    String formattedDate = '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';

    StudentApi().addSiblingStudent(selectedRelationship!,formattedDate,_studentIdController.text).then((val)async{
      print("Status :${val}");
     if(val == "success"){
       setState((){
         isLoading = false;
       });
       FirebaseMessaging.instance.subscribeToTopic(_studentIdController.text);
       showDialog(context: context, builder: (context) {
         return AlertDialog(
           shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(10.0)),
           shadowColor: const Color(0xFF2d4c9c),
           title: const Text('Sibling added'),
           titleTextStyle: const TextStyle(
               fontSize: 18.0, color: Colors.black),
           content: const Text('Sibling added successfully',
               style: TextStyle(fontSize: 16.0)),
           actions: [
             TextButton(onPressed: () {
               Navigator.pop(context);
               Navigator.pop(context);

             },
                 style: ButtonStyle(
                   shape: WidgetStateProperty.all(
                     RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(20.0),
                     ),
                   ), alignment: Alignment.bottomRight,
                   backgroundColor: const WidgetStatePropertyAll<Color>(
                       Color(0xFF2d4c9c)),
                 ), child: const Padding(
                   padding: EdgeInsets.only(left: 40.0, right: 40.0),
                   child: Center(
                       child: Text('OK', style: TextStyle(color: Colors
                           .white),)),
                 )),
           ],
         );
       });

      }
     else if(val == "exists"){
       setState((){
         isLoading = false;
       });
       showDialog(context: context, builder: (context){
         return AlertDialog(
           shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
           shadowColor: const Color(0xFF2d4c9c),
           title: const Text('Alert'),
           titleTextStyle: const TextStyle(fontSize:18.0,color:Colors.black),
           content:const Text('Sibling Student Id already exist.Hence,sibling cannot be added again', style: TextStyle(fontSize: 16.0,color: Colors.black),),
           actions: [
             TextButton(onPressed: (){
               Navigator.pop(context);
             },
                 style:ButtonStyle(
                   shape:WidgetStateProperty.all(
                     RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(20.0),
                     ),
                   ),alignment: Alignment.bottomRight,
                   backgroundColor : const WidgetStatePropertyAll<Color>(Color(0xFF2d4c9c)),
                 ),child: const Padding(
                   padding: EdgeInsets.only(left:20.0,right:20.0),
                   child: Center(child: Text('OK',style: TextStyle(color: Colors.white),)),
                 )),
           ],
         );
       });
     }
     else if(val == "not found"){
       setState((){
         isLoading = false;
       });
       showDialog(context: context, builder: (context){
         return AlertDialog(
           shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
           shadowColor: const Color(0xFF2d4c9c),
           title: const Text('Incorrect Credentials'),
           titleTextStyle: const TextStyle(fontSize:18.0,color:Colors.black),
           content:const Text('Sibling Student Id not found', style: TextStyle(fontSize: 16.0,color: Colors.black),),
           actions: [
             TextButton(onPressed: (){
               Navigator.pop(context);
             },
                 style:ButtonStyle(
                   shape:WidgetStateProperty.all(
                     RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(20.0),
                     ),
                   ),alignment: Alignment.bottomRight,
                   backgroundColor : const WidgetStatePropertyAll<Color>(Color(0xFF2d4c9c)),
                 ),child: const Padding(
                   padding: EdgeInsets.only(left:20.0,right:20.0),
                   child: Center(child: Text('OK',style: TextStyle(color: Colors.white),)),
                 )),
           ],
         );
       });
     }
     else if(val =="mismatch"){
       setState((){
         isLoading = false;
       });
       showDialog(context: context, builder: (context){
         return AlertDialog(
           shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
           shadowColor: const Color(0xFF2d4c9c),
           title: const Text('Incorrect Credentials'),
           titleTextStyle: const TextStyle(fontSize:18.0,color:Colors.black),
           content:const Text('Try Login with correct credentials - password(dob) mismatch', style: TextStyle(fontSize: 16.0,color: Colors.black),),
           actions: [
             TextButton(onPressed: (){
               Navigator.pop(context);
             },
                 style:ButtonStyle(
                   shape:WidgetStateProperty.all(
                     RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(20.0),
                     ),
                   ),alignment: Alignment.bottomRight,
                   backgroundColor : const WidgetStatePropertyAll<Color>(Color(0xFF2d4c9c)),
                 ),child: const Padding(
                   padding: EdgeInsets.only(left:20.0,right:20.0),
                   child: Center(child: Text('OK',style: TextStyle(color: Colors.white),)),
                 )),
           ],
         );
       });
     }
     else if(val.contains("inactive")){
       setState((){
         isLoading = false;
       });
       showDialog(context: context, builder: (context){
         return AlertDialog(
           shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
           shadowColor: const Color(0xFF2d4c9c),
           title: const Text('Alert'),
           titleTextStyle: const TextStyle(fontSize:18.0,color:Colors.black),
           content:Text('${_studentIdController.text} $val.Hence,he/she cannot be added', style: TextStyle(fontSize: 16.0,color: Colors.black),),
           actions: [
             TextButton(onPressed: (){
               Navigator.pop(context);

             },
                 style:ButtonStyle(
                   shape:WidgetStateProperty.all(
                     RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(20.0),
                     ),
                   ),alignment: Alignment.bottomRight,
                   backgroundColor : const WidgetStatePropertyAll<Color>(Color(0xFF2d4c9c)),
                 ),child: const Padding(
                   padding: EdgeInsets.only(left:20.0,right:20.0),
                   child: Center(child: Text('OK',style: TextStyle(color: Colors.white),)),
                 )),
           ],
         );
       });
     }
     else{
       setState((){
         isLoading = false;
       });
       showDialog(context: context, builder: (context){
         return AlertDialog(
           shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
           shadowColor: const Color(0xFF2d4c9c),
           title: const Text('Incorrect Credentials'),
           titleTextStyle: const TextStyle(fontSize:18.0,color:Colors.black),
           content:const Text('Try adding with correct details !!', style: TextStyle(fontSize: 16.0,color: Colors.black),),
           actions: [
             TextButton(onPressed: (){
               Navigator.pop(context);

             },
                 style:ButtonStyle(
                   shape:WidgetStateProperty.all(
                     RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(20.0),
                     ),
                   ),alignment: Alignment.bottomRight,
                   backgroundColor : const WidgetStatePropertyAll<Color>(Color(0xFF2d4c9c)),
                 ),child: const Padding(
                   padding: EdgeInsets.only(left:20.0,right:20.0),
                   child: Center(child: Text('OK',style: TextStyle(color: Colors.white),)),
                 )),
           ],
         );
       });
     }
    });

  }

  bool isLoading = false;
  final TextEditingController dobController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor:const Color(0xFF2d4c9c),
        title: const Text("Add Sibling", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sibling Student ID",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _studentIdController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "Enter Student ID",
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border:OutlineInputBorder(borderRadius: BorderRadius.circular(10)),

              ),
              keyboardType: TextInputType.text,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')), // Allow letters and digits
              ],
            ),
            const SizedBox(height: 15,),
            const Align(
                alignment:Alignment.topLeft,
                child: Text('Password(dob - ddMMyyyy)',style:TextStyle(fontSize: 14.0,color: Colors.grey),)),
            const SizedBox(height: 5,),
            TextFormField(
              controller:dobController,
              style: const TextStyle(fontSize: 14.0),
              keyboardType: TextInputType.number,obscureText:passwordVisible,
              decoration: InputDecoration(
                fillColor: const Color(0xFFe3e3e5),
                filled:true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none  // Change this to the desired bottom line color
                ),
                hintText: 'Enter Password',
                hintStyle: const TextStyle(fontSize: 14.0,color: Colors.grey),
                suffixIcon: IconButton(onPressed: (){
                  setState(() {
                    passwordVisible = !passwordVisible;
                  });
                },
                  icon: Icon(passwordVisible? Icons.visibility: Icons.visibility_off),color: const Color(0xFF2d4c9c),
                ),

              ),
              validator: (value) {

                  if (value == null || value.isEmpty) {
                    return "Enter Password";
                  }

                return null; // Skip validation if in "Forgot Password" mode
              },
            ),
            const SizedBox(height: 20),
            const Text(
              "Relationship",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15.0),
              child: DropdownButtonFormField<String>(
                value: selectedRelationship,

                items: relationships.map((relationship) {
                  return DropdownMenuItem(
                    value: relationship,
                    child: Text(
                      relationship,
                      style: const TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRelationship = value;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Border for the field
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Default border
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Border when focused
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  hintText: "Select Relationship",
                  hintStyle: const TextStyle(color: Colors.white70),
                ),
                menuMaxHeight: 300, // Adjust dropdown height
                borderRadius: BorderRadius.circular(12), // Add border radius for dropdown
              ),
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:isLoading?(){}: submitSibling,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2d4c9c),
                  foregroundColor: const Color(0xFF2d4c9c),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading?const Text("Adding ...",style: TextStyle(
                    color:Colors.white
                ),):const Text("Add Sibling",style: TextStyle(
                  color:Colors.white
                ),),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    super.dispose();
  }
}