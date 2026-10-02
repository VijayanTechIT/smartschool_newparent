import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_school_parent/helper/attendancemodel.dart';

import '../helper/attendanceapi.dart';
import 'StudentModel.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key,required this.name,
  required this.student,required this.attendance});

  final List<AttendanceWhole> attendance;
  final String name;
  final StudentWhole student;
  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {

  final List<String> monthNames = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];


  List<AttendanceWhole> attendanceData = [];

  @override
  void initState(){
    super.initState();
    attendanceData = widget.attendance;
  }
  final DateTime now = DateTime.now();



  Future<void> attRefresh() async {
    final DateTime firstDateOfMonth = DateTime(now.year, now.month, 1);
    final DateTime lastDateOfMonth = DateTime(now.year, now.month + 1, 0);

    final String startDate = DateFormat('yyyy-MM-dd').format(firstDateOfMonth);
    final String endDate = DateFormat('yyyy-MM-dd').format(lastDateOfMonth);

    try {
      final data = await AttendanceRecord().attendancebystudent(
        widget.student.studentId,
        widget.student.schoolCode,
        startDate,
        endDate,
      );

      setState(() {
        attendanceData = data;
      });
    } catch (e) {
      debugPrint('Attendance refresh error: $e');
    }
  }



  @override
  Widget build(BuildContext context) {

    final DateTime now = DateTime.now();
    final String monthYear = "${monthNames[now.month - 1]} ${now.year}";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2d4c9c),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30.0),
        ),
        title: const Text('Attendance'),
        centerTitle: true,
        titleTextStyle: const TextStyle(fontSize: 20.0),
      ),
      body: RefreshIndicator(
        onRefresh: attRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Row(
                children: [


                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 20),
                      child: Card(
                          child:Container(padding: const EdgeInsets.all(10.0),
                            child: Text(monthYear,textAlign: TextAlign.center,),
                          )
                      ),
                    ),
                  ),

                ],
              ),
              if(attendanceData.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top:250.0),
                  child: const Center(
                    child: Text(
                      'No Records.',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ),
                if(attendanceData.isNotEmpty)
                  Table(
                    border: TableBorder.all(),
                    columnWidths: const {
                      0: FixedColumnWidth(50),
                      1: FixedColumnWidth(100),
                      2: FixedColumnWidth(90),
                      3: FixedColumnWidth(90),

                    },
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(
                          color: Color(0xFF2d4c9c),
                        ),
                        children: [
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Center(
                                child: Text(
                                  'S.No.',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Date',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Morning',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Evening',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      ...attendanceData.map((invoice) {
                        final formattedDate = (invoice.date != null && invoice.date!.isNotEmpty)
                            ? DateFormat('dd-MM-yyyy').format(DateTime.parse(invoice.date!))
                            : '';
                        return TableRow(
                          children: [
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(10,4,4,4),
                                child: Text('${attendanceData.indexOf(invoice) + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Center(child: Text(formattedDate,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),)),
                              ),
                            ),

                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Center(
                                  child: Text(
                                    invoice.morning?.isEmpty ?? true ? '--' : invoice.morning!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: invoice.morning == 'Present'
                                          ? Colors.green
                                          : invoice.morning == 'Absent'
                                          ? Colors.red
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Center(
                                  child: Text(
                                    invoice.evening?.isEmpty ?? true ? '--' : invoice.evening!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: invoice.evening == 'Present'
                                          ? Colors.green
                                          : invoice.evening == 'Absent'
                                          ? Colors.red
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            )

                          ],
                        );
                      }),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
