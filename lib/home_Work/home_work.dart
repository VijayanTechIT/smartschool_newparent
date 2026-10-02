import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../utilis/loader.dart';
import 'home_work_bloc/home_work_bloc.dart';


class HomeworkHistoryPage extends StatelessWidget {
  final String gradeName;
  final String sectionName;
  final String schoolCode;

  const HomeworkHistoryPage({
    super.key,
    required this.gradeName,
    required this.sectionName,
    required this.schoolCode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        titleTextStyle: const TextStyle(fontSize: 20.0),
        backgroundColor:const Color(0xFF2d4c9c),
        title: const Text("Homework", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),

      ),
      body: BlocBuilder<HomeWorkBloc, HomeWorkState>(
        builder: (context, state) {
          if (state is HomeWorkLoading) {
            return const Center(child: Loader());
          } else if (state is HomeWorkError) {
            return Center(child: Text(state.message));
          } else if (state is HomeWorkLoaded) {
            final homeworks = state.homeworks;

            if (homeworks.isEmpty) {
              return const Center(
                child: Text(
                  "No homework found.",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: homeworks.length,
                itemBuilder: (context, index) {
                  final entry = homeworks[index];
                  final rawDate = entry['date'] ?? '';
                  final details = entry['details'] as List<dynamic>?;

                  String formattedDate = rawDate;
                  try {
                    final parsedDate = DateFormat('yyyy-MM-dd').parse(rawDate);
                    final formatted = DateFormat('dd-MM-yyyy').format(parsedDate);
                    final dayName = DateFormat('EEEE').format(parsedDate);
                    formattedDate = "$formatted ($dayName)";
                  } catch (_) {
                    // fallback to rawDate
                  }

                  /// ✅ Parse your `details` using your own logic:
                  final parsedList = details != null && details.isNotEmpty
                      ? details.map((entry) {
                    final homeWorkDetailsId = entry['home_work_details_id']?.toString() ?? '';
                    final subjectId = entry['subject_id']?.toString() ?? '';
                    final homeworkDesc = entry['home_work_desc']?.toString() ?? '';
                    final subjectName = entry['subject_name']?.toString() ?? 'Unknown';
                    return {
                      'homeWorkDetailsId': homeWorkDetailsId,
                      'subjectId': subjectId,
                      'homework': homeworkDesc,
                      'subject': subjectName,
                    };
                  }).toList()
                      : [];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "📅 $formattedDate",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Divider(color: Colors.grey),
                          const SizedBox(height: 5),
                          ...parsedList.map((item) {
                            final subject = item['subject'] ?? '';
                            final content = item['homework'] ?? '';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$subject:',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    content,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                });

                }

          return const SizedBox(); // Initial/Empty state
        },
      ),
    );
  }




}
