import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../models/student_class_test_model.dart';
import '../student/StudentModel.dart';
import '../utilis/loader.dart';
import 'class_test_bloc.dart';

class IndividualClassTestReport extends StatefulWidget {
  const IndividualClassTestReport({super.key,
    required this.student,
  });


  final StudentWhole student;
  @override
  State<IndividualClassTestReport> createState() => _IndividualClassTestReportState();
}

class _IndividualClassTestReportState extends State<IndividualClassTestReport> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2d4c9c),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30.0),
        ),
        title: const Text('Class Test - Weekly Report'),
        centerTitle: true,
        titleTextStyle: const TextStyle(fontSize: 20.0),
      ),
      body: Column(
        children: [
          // Student Info
          Card(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        Text("${widget.student.studyingGrade} - ${widget.student.studyingSection}"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top:10.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFF2d4c9c),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: const Text(
                'Weekly Report',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          // Marks Table
          Expanded(
            child: BlocBuilder<StClassTestBloc, StClassTestState>(
              builder: (context, state) {
                if (state is StClassTestInitial) {
                  return const Center(child: Text("Select Exam to view data"));
                } else if (state is StClassTestLoading) {
                  return const Loader();
                } else if (state is StClassTestLoaded) {
                  if (state.classTestList.isNotEmpty) {
                    var weekDateMap = groupByWeekAndDate(state.classTestList);

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 40),
                      children: weekDateMap.entries.map((weekEntry) {
                        final weekLabel = weekEntry.key;
                        final dateMap = weekEntry.value;

                        final allTestsForWeek = dateMap.values.expand((tests) => tests).toList();
                        final stats = calculateWeeklyStats(allTestsForWeek);

                        final totalScored = stats['scored']!;
                        final totalMax = stats['max']!;
                        final percentage = stats['percentage']!;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 3,
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            backgroundColor: Colors.grey.shade50,
                            initiallyExpanded: false,
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Week label and % display
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      weekLabel,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: percentage >= 50
                                            ? Colors.green.shade100
                                            : percentage >= 40
                                            ? Colors.orange.shade100
                                            : Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        "${percentage.toStringAsFixed(2)}%",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: percentage >= 50
                                              ? Colors.green.shade800
                                              : percentage >= 40
                                              ? Colors.orange.shade800
                                              : Colors.red.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Total marks summary
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    "Total: ${totalScored.toStringAsFixed(0)} / "
                                        "${totalMax.toStringAsFixed(0)}",
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                                // Optional progress bar
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: LinearProgressIndicator(
                                    value: percentage / 100,
                                    minHeight: 5,
                                    backgroundColor: Colors.grey[300],
                                    color: percentage >= 50
                                        ? Colors.green
                                        : percentage >= 40
                                        ? Colors.orange
                                        : Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),

                            // List of daily test details
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                color: Colors.grey[200],
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
                                    SizedBox(width: 95, child: Text("Date", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
                                    SizedBox(width: 85, child: Text("Subject", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
                                    SizedBox(width: 60, child: Text("Scored", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
                                    SizedBox(width: 60, child: Text("Max", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
                                  ],
                                ),
                              ),
                              ...dateMap.entries.expand((dateEntry) {
                                final dateLabel = dateEntry.key;
                                final tests = dateEntry.value;

                                return tests.map((test) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: const BoxDecoration(
                                      border: Border(bottom: BorderSide(color: Colors.grey, width: 0.3)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(width: 95, child: Text(dateLabel, style: const TextStyle(fontSize: 12))),
                                        SizedBox(width: 85, child: Text(test.subjectName, style: const TextStyle(fontSize: 12))),
                                        SizedBox(width: 60, child: Text(test.mark, style: const TextStyle(fontSize: 12))),
                                        SizedBox(width: 60, child: Text(test.maxMarks, style: const TextStyle(fontSize: 12))),
                                      ],
                                    ),
                                  );
                                });
                              }),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }
                  else {
                    return const Center(child: Text("No Records Found"));
                  }
                } else {
                  return const Center(child: Text("No Records Found"));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> calculateWeeklyStats(List<StudentClassTestModel> tests) {
    double totalScored = 0;
    double totalMax = 0;

    for (var test in tests) {
      totalScored += double.tryParse(test.mark) ?? 0;
      totalMax += double.tryParse(test.maxMarks) ?? 0;
    }

    double percentage = (totalMax == 0) ? 0 : (totalScored / totalMax) * 100;

    return {
      'scored': totalScored,
      'max': totalMax,
      'percentage': percentage,
    };
  }


  Map<String, Map<String, List<StudentClassTestModel>>> groupByWeekAndDate(
      List<StudentClassTestModel> data)
  {
    // --- Step 1: Sort input by date (latest first) ---
    data.sort((a, b) => b.testDate.compareTo(a.testDate));

    Map<String, Map<String, List<StudentClassTestModel>>> weekMap = {};

    for (var test in data) {
      // Week range: Sunday → Saturday
      DateTime sunday =
      test.testDate.subtract(Duration(days: test.testDate.weekday % 7));
      DateTime saturday = sunday.add(const Duration(days: 6));
      String weekLabel =
          "${DateFormat('dd-MM-yyyy').format(sunday)} to ${DateFormat('dd-MM-yyyy').format(saturday)}";

      String dateLabel = DateFormat('dd-MM-yyyy').format(test.testDate);

      weekMap.putIfAbsent(weekLabel, () => {});
      weekMap[weekLabel]!.putIfAbsent(dateLabel, () => []);
      weekMap[weekLabel]![dateLabel]!.add(test);
    }

    // --- Step 2: Sort weeks by start date (latest first) ---
    final sortedWeeks = weekMap.entries.toList()
      ..sort((a, b) {
        final aStart = DateFormat('dd-MM-yyyy').parse(a.key.split(" to ").first);
        final bStart = DateFormat('dd-MM-yyyy').parse(b.key.split(" to ").first);
        return bStart.compareTo(aStart); // latest first
      });

    // --- Step 3: Sort dates inside each week (latest first) ---
    Map<String, Map<String, List<StudentClassTestModel>>> sortedWeekMap = {};
    for (var weekEntry in sortedWeeks) {
      final sortedDates = weekEntry.value.entries.toList()
        ..sort((a, b) {
          final aDate = DateFormat('dd-MM-yyyy').parse(a.key);
          final bDate = DateFormat('dd-MM-yyyy').parse(b.key);
          return bDate.compareTo(aDate); // latest first
        });

      Map<String, List<StudentClassTestModel>> sortedDateMap = {};
      for (var dateEntry in sortedDates) {
        // Also sort tests inside each date (latest first)
        dateEntry.value.sort((a, b) => b.testDate.compareTo(a.testDate));
        sortedDateMap[dateEntry.key] = dateEntry.value;
      }

      sortedWeekMap[weekEntry.key] = sortedDateMap;
    }

    return sortedWeekMap;
  }

}
