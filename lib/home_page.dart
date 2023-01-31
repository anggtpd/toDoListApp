import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key}) : super(key: key);

  final TextEditingController newTask = TextEditingController();

  final FirebaseFirestore db = FirebaseFirestore.instance;

  final task = <String, dynamic>{"taskName": "Meeting penting", "value": false};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
      ),
      body: Column(
        children: [
          taskList(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: newTask,
              decoration: InputDecoration(
                  hintText: 'Add a new task...',
                  suffix: GestureDetector(
                    onTap: () {
                      newTask.clear();
                    },
                    child: const Icon(Icons.clear),
                  )),
              onSubmitted: (newTask) async {
                final taskbaru = <String, dynamic>{
                  "taskName": newTask,
                  "value": false
                };

                try {
                  await db
                      .collection("tasks")
                      .add(taskbaru)
                      .then((DocumentReference doc) => print('ID ${doc.id}'));
                } catch (e) {
                  print(e);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget taskList() {
    return StreamBuilder<QuerySnapshot>(
      stream: db.collection("tasks").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        final hasil = snapshot.data?.docs;
        return Expanded(
            child: ListView.builder(
          itemCount: hasil?.length,
          itemBuilder: (context, index) {
            final hasiltask = hasil![index];
            final taskName = hasiltask.get("taskName");

            return ListTile(
                title: Text(taskName),
                onTap: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          title: const Text('Confirmation'),
                          content: Text(
                              'Are you sure to delete this task $taskName?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'Cancel'),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                db
                                    .collection("tasks")
                                    .doc(hasiltask.id)
                                    .delete();
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        )));
          },
        ));
      },
    );
  }
}
