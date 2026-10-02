import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_school_parent/internet_conn/internet_connection_bloc.dart';
import '../models/exams_model_class.dart';
import '../models/marks_model_class.dart';
import '../student/StudentModel.dart';
import '../utilis/loader.dart';
import 'marks_bloc.dart';
import 'no_internet_screen.dart';

class MarksScreen extends StatefulWidget {
  const MarksScreen({
    super.key,
    required this.marksList,
    required this.examList,
    required this.examName,
    required this.student,
  });

  final List<ExamsModelClass> examList;
  final StudentWhole student;
  final String examName;
  final List<MarksModelClass> marksList;

  @override
  State<MarksScreen> createState() => _MarksScreenState();
}

class _MarksScreenState extends State<MarksScreen> {
  ExamsModelClass? selectedExam;

  @override
  void initState() {
    super.initState();

    if(widget.examName != "" || widget.examName != '') {
      // Find the matching exam from the list based on widget.examName
      selectedExam = widget.examList.firstWhere(
            (exam) => exam.examName == widget.examName,
        orElse: () => widget.examList.first,
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 550), // Set your desired max width
          child: Center(
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: const Color(0xFF2d4c9c),
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30.0),
                ),
                title: const Text('Marks Scored'),
                centerTitle: true,
                titleTextStyle: const TextStyle(fontSize: 20.0),
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    // Exam Selection Dropdown
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: const Text(
                              "Select Exam",
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: DropdownButtonFormField<ExamsModelClass>(
                              value: selectedExam,
                              borderRadius: BorderRadius.circular(20),
                              onChanged: (ExamsModelClass? newValue) {
                                 if(context.read<InternetConnectionBloc>().state is InternetDisconnected){
                                   Navigator.push(
                                     context,
                                     MaterialPageRoute(builder: (context) => const NoInternetScreen(
                                       shouldPopOnReconnect: true,
                                     )),
                                   ).then((onValue){
                                     setState(() {
                                       selectedExam = newValue!;
                                       context.read<MarksBloc>().add(FetchMarks(
                                         selectedExam!.examId!,
                                         widget.student.schoolCode,
                                         widget.student.studentId,
                                       ));
                                     });
                                   });
                                 }else {
                                   setState(() {
                                     selectedExam = newValue!;
                                     context.read<MarksBloc>().add(FetchMarks(
                                       selectedExam!.examId!,
                                       widget.student.schoolCode,
                                       widget.student.studentId,
                                     ));
                                   });
                                 } },
                              dropdownColor: const Color(0xFF2d4c9c),
                              iconDisabledColor: Colors.white,
                              iconEnabledColor: Colors.white,
                              items: widget.examList.map<DropdownMenuItem<ExamsModelClass>>(
                                    (exam) {
                                  return DropdownMenuItem<ExamsModelClass>(
                                    value: exam,
                                    child: Text(
                                      exam.examName,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  );
                                },
                              ).toList(),
                              isExpanded: true,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFF2d4c9c),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Display Student Info
                    Card(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text("Name"),
                                  Text("Student Id"),
                                  Text("Grade & Section"),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.student.name),
                                  Text(widget.student.studentId),
                                  Text(
                                    "${widget.student.studyingGrade} - ${widget.student.studyingSection}",
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Marks Table
                    SingleChildScrollView(
                      child: SizedBox(
                        height:MediaQuery.of(context).size.height * 0.7,
                        child: BlocBuilder<MarksBloc, MarksState>(
                          builder: (context, state) {
                            if (state is MarksLoading) {
                              return const Center(child: Loader());
                            } else if (state is MarksLoaded) {
                              List<MarksModelClass> marksList = state.marksList;
                              if(state.marksList.isNotEmpty){
                              int totalMarks = marksList.fold(
                                  0, (sum, data) => sum + (int.tryParse(data.mark) ?? 0));
                              int outOf = marksList.fold(
                                  0, (sum, data) => sum + (int.tryParse(data.maxMarks) ?? 0));
                              double percentage = outOf == 0 ? 0 : (totalMarks / outOf) * 100;

                              Color percentColor;
                              if (percentage >= 50) {
                                percentColor = Colors.green;
                              } else if (percentage >= 40) {
                                percentColor = Colors.orange;
                              } else {
                                percentColor = Colors.red;
                              }
                              return Column(
                                children: [
                                  SingleChildScrollView(
                                    child: SizedBox(

                                      width: screenWidth,
                                      child: DataTable(
                                        columnSpacing: 10,
                                        columns: const [
                                          DataColumn(
                                            label: SizedBox(
                                              width: 120,
                                              child: Text(
                                                'Subject',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width: 100,
                                              child: Text(
                                                'Marks',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width: 100,
                                              child: Text(
                                                'Max Marks',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                        rows: marksList.map((data) {
                                          return DataRow(
                                            cells: [
                                              DataCell(
                                                SizedBox(
                                                  width: 120,
                                                  child: Text(
                                                    data.subjectId,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w400,
                                                      fontSize: 12.0,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: 100,
                                                  child: Text(
                                                    data.mark,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w400,
                                                      fontSize: 12.0,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: 100,
                                                  child: Text(
                                                    data.maxMarks,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w400,
                                                      fontSize: 12.0,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Card(

                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),

                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Total Marks Row
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text(
                                                  'Total Marks',
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  '$totalMarks / $outOf',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 6),

                                            // Percentage Row
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text(
                                                  'Percentage',
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  '${percentage.toStringAsFixed(2)}%',
                                                  style: TextStyle(
                                                    color: percentColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 5),

                                            // Progress Bar
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(5),
                                              child: LinearProgressIndicator(
                                                value: percentage / 100,
                                                minHeight: 6,
                                                backgroundColor: Colors.grey.shade300,
                                                color: percentColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                          }
                              else {
                                return const Center(child: Text("No Records Found",
                                    style: TextStyle(


                                    fontSize:16  ),));
                              }
                            } else {
                              return const Center(child: Text("No Records Found",
                                style: TextStyle(
                                    fontSize:16  ),));
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
