import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
                  await db.collection("tasks").add(taskbaru);
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
            return ListTile(
              title: Text(hasiltask.get("taskName")),
            );
          },
        ));
      },
    );
  }
}

class LoginPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              child: const Text("Login"),
              onPressed: () async {
                final email = _emailController.text;
                final password = _passwordController.text;

                try {
                  final user = await _auth.signInWithEmailAndPassword(
                      email: email, password: password);

                  if (user == null) {
                    print('user sign out');
                  } else {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MyHomePage()));
                  }
                } catch (e) {
                  print(e);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
