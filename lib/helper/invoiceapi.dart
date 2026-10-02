import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../helper/invoiceModel.dart';

class InvoiceApi{
  var url = Constants.url;

  Future invoiceIdData(String center_code,String invoice_date)async{
    var orderUrl = "$url/invoiceidcount.php";
    final response = await http.post(Uri.parse(orderUrl),body:{"center_code":center_code,
    "invoice_date":invoice_date
    });
    if(response.statusCode == 200){
      var data = json.decode(response.body);

      return data;
    }else{
      return 0;
    }
  }


  Future<String> insertInvoice(List<InvoiceModel> invoice) async {
    var insertpayurl = "$url/insertinvoices.php";
    List<Map<String, dynamic>> jsonList = invoice.map((attend) => attend.toJsonAdd()).toList();
    String jsonString = json.encode(jsonList);

    final response = await http.post(
      Uri.parse(insertpayurl),    body: jsonString,
    );
    if (response.statusCode == 200) {
      return "success";
    } else {
      return "Error adding data";
    }
  }




  Future<List<InvoiceModelWhole>> getAllInvoices(String centerCode) async {
    var inserturl = "$url/getallinvoices.php";
    final response = await http.post(Uri.parse(inserturl), body:{
      "center_code": centerCode,

    });
    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      // Parse the JSON response

      List<InvoiceModelWhole> datalist = [];

      try{
        for(var datasjson in result){
          datalist.add(InvoiceModelWhole.fromJson(datasjson));
        }
      }catch(e){
        datalist.clear();
      }
      return datalist;

    } else {
      return <InvoiceModelWhole>[];
    }
  }


  Future<List<InvoiceModelWhole>> getAllInvoicesStudent(String centerCode,String student_id) async {
    var inserturl = "$url/getinvoicebystudentid.php";
    final response = await http.post(Uri.parse(inserturl), body:{
      "center_code": centerCode,
      "student_id":student_id

    });
    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      // Parse the JSON response

      List<InvoiceModelWhole> datalist = [];

      try{
        for(var datasjson in result){
          datalist.add(InvoiceModelWhole.fromJson(datasjson));
        }
      }catch(e){
        datalist.clear();
      }
      return datalist;

    } else {
      return <InvoiceModelWhole>[];
    }
  }



}