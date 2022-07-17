import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:todo/Task.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MyHomePage();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _primaryBg = const Color(0xFF11111D);
  final _secondaryBg = const Color(0xFF191933);
  final _accent = const Color(0xFF545CFF);
  final _newTaskController = TextEditingController();
  List<Task> tasks = [];

  void updateList(DatabaseEvent event) {
    List<Task> newList = [];
    for (final child in event.snapshot.children) {
      Map<String, dynamic> data = jsonDecode(jsonEncode(child.value));
      Task newTask = Task.fromJson(data);
      if (!newTask.status) {
        newList.add(newTask);
      }
    }
    for (final child in event.snapshot.children) {
      Map<String, dynamic> data = jsonDecode(jsonEncode(child.value));
      Task newTask = Task.fromJson(data);
      if (newTask.status) {
        newList.add(newTask);
      }
    }
    setState(() {
      tasks = newList;
    });
  }

  void addNewTask() {
    String newTaskInput = _newTaskController.text.trim();
    if (newTaskInput.isEmpty) {
      return;
    }

    DatabaseReference newPostRef =
        FirebaseDatabase.instance.ref("items").push();
    Task task = Task(id: newPostRef.key!, task: newTaskInput, status: false);
    newPostRef.set(task.toJson());
  }

  void toggleStatus(int index) {
    FirebaseDatabase.instance.ref("items/${tasks[index].id}/").update({
      "status": !tasks[index].status
    });
  }

  @override
  void initState() {
    super.initState();
    FirebaseDatabase.instance.ref("items/").onValue.listen(updateList);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: _primaryBg,
      ),
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/background.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, right: 8.0, top: 50.0),
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _secondaryBg,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextField(
                              controller: _newTaskController,
                              cursorColor: Colors.white,
                              style: GoogleFonts.comfortaa(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                labelText: "Add a new task...",
                                labelStyle: GoogleFonts.comfortaa(
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: InkWell(
                            onTap: addNewTask,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: _accent,
                                    borderRadius: BorderRadius.circular(18.0)),
                                width: 40.0,
                                height: 40.0,
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: SvgPicture.asset(
                                    "assets/PlusCircle.svg",
                                    color: Colors.white,
                                    width: 15.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 32.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _accent,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  tasks[index].task,
                                  softWrap: true,
                                  style: GoogleFonts.comfortaa(
                                    fontSize: 15.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Checkbox(
                                checkColor: Colors.white,
                                fillColor: MaterialStateProperty.all(_primaryBg),
                                value: tasks[index].status,
                                onChanged: (value) {
                                  toggleStatus(index);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
