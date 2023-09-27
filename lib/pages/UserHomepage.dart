import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
//import 'UserTask.dart';
import 'UserPlans.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key, required this.email});
  final String? email;

  @override
  State<UserHomePage> createState() => _UserHomePageState(email);
}

class _UserHomePageState extends State<UserHomePage> {
  final PageController pageController = PageController(initialPage: 0);
  late int _selectedIndex = 0;
  final TextEditingController plan_name = TextEditingController();
  final String? email;
  _UserHomePageState(this.email);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("User home page"),
        actions: [
          Hero(
            tag: 'hello $email',
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => FirebaseAuth.instance.signOut(),
            ),
          ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: kBottomNavigationBarHeight,
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.brown,
            unselectedItemColor: Colors.black,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
                pageController.jumpToPage(index);
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.square_list),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.tag),
                label: '',
              ),
            ],
          ),
        ),
      ),
      body: Column(
          // Wrap the TextField and PageView in a Column
          children: [
            Expanded(
              // Use Expanded to make the PageView take remaining space
              child: PageView(
                controller: pageController,
                children: <Widget>[
                  Center(
                    child: UserPlans(email: email),
                  ),
                  // Center(
                  //   child: Categories(),
                  // ),
                ],
              ),
            ),
          ]),
    );
  }
}
