import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:collection/collection.dart';
import "./utils.dart";
import "./session.dart";

// FirebaseDatabase database = FirebaseDatabase.instance;
final db = FirebaseFirestore.instance;
const appTitle = "TrainWithSomeone";

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  runApp(const TrainWithSomeoneApp());
}

class TrainWithSomeoneApp extends StatelessWidget {
  const TrainWithSomeoneApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(useMaterial3: true),
      home: const App(),
    );
  }
}

class App extends StatefulWidget {
  const App({super.key});
  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  int currentPageIdx = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text(appTitle), backgroundColor: Colors.blueGrey),
      body: const <Widget>[HomePage(), Text("Manage")][currentPageIdx],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIdx = index;
          });
        },
        animationDuration: Durations.short1,
        indicatorColor: Colors.blueGrey,
        selectedIndex: currentPageIdx,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.edit),
            icon: Icon(Icons.edit_outlined),
            label: "Manage",
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              maxWidth: constraints.maxWidth,
            ),
            child: StreamBuilder<QuerySnapshot>(
              // TODO: query by user and limit query
              stream: db
                  .collection("sessions")
                  .orderBy("date", descending: true)
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
                                db: db,
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
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }
}
