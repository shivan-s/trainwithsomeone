import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseDatabase database = FirebaseDatabase.instance;
    final db = FirebaseFirestore.instance;

    const sessions = ["Test1", "Test2", "Test3", "Test4"];
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children:
                        sessions.map((s) => SessionSection(name: s)).toList(),
                  )),
            );
          },
        ),
      ),
    );
  }
}

class SessionSection extends StatelessWidget {
  const SessionSection({super.key, required this.name});
  final String name;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: ExpansionTile(
          title: Center(child: Text(name)),
          children: [Text(name)],
        ),
      ),
    );
  }
}
