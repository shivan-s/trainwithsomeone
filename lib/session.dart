import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Session {
  final String id;
  final Timestamp date;
  Session({
    required this.id,
    required this.date,
  });
}

class Exercise {
  final String id;
  final int repetitions;
  final int sets;
  final dynamic sessionId;
  final dynamic exerciseTypeId;
  final String? notes;
  final int weight;
  final String unit;
  Exercise({
    required this.id,
    required this.repetitions,
    required this.sets,
    required this.sessionId,
    required this.exerciseTypeId,
    required this.weight,
    required this.unit,
    this.notes,
  });
}

class ExerciseType {
  final String id;
  final String name;
  final String description;
  ExerciseType({
    required this.id,
    required this.name,
    required this.description,
  });
}

class SessionWidget extends StatelessWidget {
  final FirebaseFirestore db;
  final String id;
  final Timestamp date;
  const SessionWidget({
    super.key,
    required this.db,
    required this.id,
    required this.date,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: ExpansionTile(
          title: Center(child: Text(DateFormat.EEEE().format(date.toDate()))),
          children: [
            StreamBuilder<QuerySnapshot>(
                stream: db
                    .collection('exercises')
                    .where("sessionId", isEqualTo: db.doc("/sessions/$id"))
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error"));
                  } else {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        {
                          return const Center(child: Text("No connection"));
                        }
                      case ConnectionState.waiting:
                        {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.blueGrey));
                        }
                      case ConnectionState.done || ConnectionState.active:
                        {
                          final data = snapshot.data?.docs.toList();
                          if (data!.isEmpty) {
                            return const Center(child: Text("No Exercises"));
                          } else {
                            List<Exercise> exercises = [];
                            for (var exercise in data) {
                              exercises.add(
                                Exercise(
                                  id: exercise.id,
                                  repetitions: exercise['repetitions'],
                                  sets: exercise['sets'],
                                  exerciseTypeId: exercise["exerciseTypeId"],
                                  sessionId: exercise["sessionId"],
                                  weight: exercise["weight"],
                                  unit: exercise["unit"],
                                  notes: exercise["notes"],
                                ),
                              );
                            }
                            return DataTable(
                              columns: const [
                                DataColumn(label: Text("Exercise")),
                                DataColumn(label: Text("Sets")),
                                DataColumn(label: Text("Reps")),
                                DataColumn(label: Text("Weight")),
                              ],
                              rows: exercises.map((e) {
                                return DataRow(cells: [
                                  DataCell(StreamBuilder<DocumentSnapshot>(
                                      stream: e.exerciseTypeId.snapshots(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<DocumentSnapshot>
                                              snapshot) {
                                        if (snapshot.hasError) {
                                          return const Text("Error");
                                        } else {
                                          switch (snapshot.connectionState) {
                                            case ConnectionState.none:
                                              {
                                                return const Text(
                                                    "No connection");
                                              }
                                            case ConnectionState.waiting:
                                              {
                                                return const CircularProgressIndicator(
                                                    color: Colors.blueGrey);
                                              }
                                            case ConnectionState.done ||
                                                  ConnectionState.active:
                                              {
                                                final data = snapshot.data;
                                                if (!data!.exists) {
                                                  return const Text("Error");
                                                } else {
                                                  return Text(data["name"]);
                                                }
                                              }
                                          }
                                        }
                                      })),
                                  DataCell(Text(e.repetitions.toString())),
                                  DataCell(Text(e.sets.toString())),
                                  DataCell(
                                      Text("${e.weight.toString()} ${e.unit}"))
                                ]);
                              }).toList(),
                            );
                          }
                        }
                    }
                  }
                })
          ],
        ),
      ),
    );
  }
}

class WeekHeaderWidget extends StatelessWidget {
  final String header;
  const WeekHeaderWidget({super.key, required this.header});
  @override
  Widget build(BuildContext context) {
    final startOfWeekDate = DateTime.parse(header.split("--")[0]);
    final endOfWeekDate = DateTime.parse(header.split("--")[1]);
    String startOfWeek = DateFormat.MMMMd().format(startOfWeekDate).toString();
    final endOfWeek = DateFormat.yMMMMd().format(endOfWeekDate).toString();

    if (startOfWeekDate.year != endOfWeekDate.year) {
      startOfWeek = DateFormat.yMMMMd().format(startOfWeekDate).toString();
    }
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Row(children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 10, right: 15),
              child: const Divider(color: Colors.grey, height: 1),
            ),
          ),
          Text(startOfWeek),
          const Text(" to ", style: TextStyle(color: Colors.grey)),
          Text(endOfWeek),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 10, right: 15),
              child: const Divider(color: Colors.grey, height: 1),
            ),
          ),
        ]));
  }
}
