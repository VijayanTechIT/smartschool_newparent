class User{
  final String center_code;
  final String centerName;
  final String centerAddress;
  final String upi_id;
  final String username;
  final String contactNumber;
  final String emailId;
  final String userpassword;
  final String approvalStatus;
User({required this.center_code,required this.centerName,required this.centerAddress,
  required this.username,required this.contactNumber,required this.upi_id,required this.emailId,
  required this.userpassword,required this.approvalStatus});

factory User.fromJson(Map<String,dynamic>json){
  return User(
    center_code:json['center_code'] ,
    centerName: json['centerName'],
    centerAddress:json['centerAddress'] ,
    username: json['username'],
    contactNumber: json['contactNumber'],
    emailId:json['emailId'] ,
    upi_id:json['upi_id'],
    userpassword: json['userpassword'],
    approvalStatus:json['approvalStatus']
  );
}

Map<String,dynamic>toJsonAdd(){
  return{
    "center_code":center_code,
    "centerName":centerName,
    "centerAddress":centerAddress,
     "upi_id":upi_id,
    "username": username,
    "contactNumber": contactNumber,
    "emailId":emailId,
    "userpassword":userpassword,
    "approvalStatus":approvalStatus,
  };
}
}




class Userdatas{
 String? id;
 String? center_code;
 String? centerName;
 String? centerAddress;
 String? username;
 String? contactNumber;
 String? emailId;
 String? upi_id;
 String? userpassword;
 String? approvalStatus;

  Userdatas({
    this.id,
    this.center_code,
    this.centerName,
    this.centerAddress,
    this.upi_id,
    this.username,
    this.contactNumber,
    this.emailId,
    this.userpassword,
    this.approvalStatus});
 factory Userdatas.fromJson(Map<String, dynamic> json) {
   return Userdatas(
     id: json['id'].toString(),
     center_code: json['center_code'] ?? "",
     centerName: json['centerName'] ?? "",
     centerAddress: json['centerAddress'] ?? "",
     username: json['username'] ?? "",
     contactNumber: json['contactNumber'] ?? "",
     upi_id:json['upi_id'] ?? "",
     emailId: json['emailId'] ?? "",
     userpassword: json['userpassword'] ?? "",
     approvalStatus: json['approvalStatus'] ?? "",
   );
 }

}

class UserUpdateDelete{
  late final int id;
  final String center_code;
  final String centerName;
  final String centerAddress;
  final String username;
  final String contactNumber;
  final String emailId;
  final String upi_id;
  final String userpassword;
  final String approvalStatus;
  UserUpdateDelete({required this.id,required this.upi_id,required this.center_code,required this.centerName,required this.centerAddress,required this.username,required this.contactNumber,required this.emailId,required this.userpassword,required this.approvalStatus});

  factory UserUpdateDelete.fromJson(Map<String,dynamic>json){
    return UserUpdateDelete(
        id:json["id"],
        center_code:json["center_code"] ,
        centerName: json["centerName"],
        centerAddress:json["centerAddress"] ,
        username: json["username"],
        emailId:json["emailId"] ,
        upi_id:json["upi_id"],
        contactNumber: json["contactNumber"],
        userpassword: json["userpassword"],
        approvalStatus:json["approvalStatus"]
    );
  }

  Map<String,dynamic>toJsonUpdateDelete(){
    return{
      "id": id,
      "center_code":center_code,
      "centerName":centerName,
      "centerAddress":centerAddress ,
      "username": username,
      "contactNumber": contactNumber,
      "emailId":emailId,
      "upi_id":upi_id,
      "userpassword":userpassword,
      "approvalStatus":approvalStatus,
    };
  }
}

class Signin{
  final String emailId;
  final String userpassword;

  Signin({required this.emailId,required this.userpassword});

  factory Signin.fromJson(Map<String,dynamic>json){
    return Signin(
        emailId:json['emailId'] ,
        userpassword: json['userpassword'],
       );
  }

  Map<String,dynamic>toJsonSignin(){
    return{
      "emailId":emailId,
      "userpassword":userpassword,
      };
  }
}
