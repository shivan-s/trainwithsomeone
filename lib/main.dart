import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart';
import 'package:collection/collection.dart';
import "./utils.dart";

// FirebaseDatabase database = FirebaseDatabase.instance;
final db = FirebaseFirestore.instance;

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  runApp(const MyApp());
}

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
  Exercise({
    required this.id,
    required this.repetitions,
    required this.sets,
    required this.sessionId,
    required this.exerciseTypeId,
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const String appTitle = "TrainWithSomeone";
    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
            title: const Text(appTitle), backgroundColor: Colors.blueGrey),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                      maxWidth: constraints.maxWidth,
                    ),
                    child: StreamBuilder<QuerySnapshot>(
                        stream: db.collection("sessions").snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return const Center(child: Text("Error"));
                          } else if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.blueGrey));
                          } else {
                            final data = snapshot.data?.docs.toList();
                            if (data!.isEmpty) {
                              return const Center(child: Text("No Sessions"));
                            } else {
                              List<Session> sessions = [];
                              for (var session in data) {
                                sessions.add(Session(
                                  id: session.id,
                                  date: session["date"],
                                ));
                              }
                              final map = groupBy(
                                  sessions, (s) => weekRange(s.date.toDate()));
                              List<StatelessWidget> widgets = [];
                              for (MapEntry e in map.entries) {
                                widgets.add(WeekHeaderWidget(header: e.key));
                                for (var s in e.value) {
                                  widgets.add(SessionWidget(
                                    id: s.id,
                                    date: s.date,
                                  ));
                                }
                              }
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: widgets,
                              );
                            }
                          }
                        })));
          },
        ),
      ),
    );
  }
}

class SessionWidget extends StatelessWidget {
  final String id;
  final Timestamp date;
  const SessionWidget({
    super.key,
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
                stream: db.collection('exercises').where("sessionId", isEqualTo: ).snapshots(),
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
                                ),
                              );
                            }
                            return Column(
                              children: exercises.map((e) {
                                return Row(children: [
                                  Expanded(
                                      child: Text(e.exerciseTypeId.toString())),
                                  Expanded(
                                      child: Text(e.repetitions.toString())),
                                  const Expanded(child: Text(' x ')),
                                  Expanded(child: Text(e.sets.toString())),
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
