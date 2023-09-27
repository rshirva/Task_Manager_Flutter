import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pages/home.dart';
import 'pages/login_page.dart';
import 'pages/UserHomepage.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: myPage(),
    );
  }
}

class myPage extends StatelessWidget {
  const myPage({super.key});

  Future<bool> authenticateAdmin(String? email) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('Users')
        .where('email', isEqualTo: email)
        .get();

    if (query.docs.isNotEmpty && query.docs[0]['Designation'] == 'Admin') {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('There is some error!'));
          } else if (snapshot.hasData) {
            User? user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              String? email = user.email;
              return FutureBuilder<bool>(
                future: authenticateAdmin(email),
                builder: (context, adminSnapshot) {
                  if (adminSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (adminSnapshot.hasData) {
                    if (adminSnapshot.data!) {
                      return AdminHomePage();
                    } else {
                      return UserHomePage(email: email);
                    }
                  } else {
                    print("Invalid Login Credentials");
                    return LoginDemo();
                  }
                },
              );
            }
          } else {
            print("Invalid Login Credentials");
            return LoginDemo();
          }

          // Add a default return statement here
          return Container(); // You can replace this with an appropriate default widget
        },
      ),
    );
  }
}
