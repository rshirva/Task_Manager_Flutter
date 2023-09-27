// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors
//import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'home.dart';
import 'package:task_manager/main.dart';

class LoginDemo extends StatefulWidget {
  @override
  State<LoginDemo> createState() => _LoginDemoState();
}

class _LoginDemoState extends State<LoginDemo> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Future<void> signIn() async {
  //     await FirebaseAuth.instance.signInWithEmailAndPassword(
  //       email: emailController.text.trim(),
  //       password: passwordController.text.trim(),
  //     );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Login Page"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 110.0),
              child: Center(
                child: SizedBox(
                    width: 200,
                    height: 100,
                    /*decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50.0)),*/
                    child: Image.asset('lib/assets/login.png')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 110, left: 15, right: 15),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    labelText: 'Phone number, email or username',
                    hintText: 'Enter valid email id as abc@gmail.com'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 0),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    labelText: 'Password',
                    hintText: 'Enter secure password'),
              ),
            ),
            SizedBox(
              height: 65,
              width: 360,
              child: SizedBox(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Hero(
                    tag: 'buttonforlogin',
                    child: ElevatedButton(
                      child: Text(
                        'Log in',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onPressed: () {
                        signIn();
                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Container(
                child: Center(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 62),
                    child: Text('Forgot your login details? '),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 1.0),
                    child: InkWell(
                        onTap: () {
                          print('hello');
                        },
                        child: Text(
                          'Get help logging in.',
                          style: TextStyle(fontSize: 14, color: Colors.blue),
                        )),
                  )
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }

  Future<void> signIn() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      print(e);
    }
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
