import '../Alert_Dialogues/Plan_AlertDialogue.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:task_manager/pages/Display_Plan_Page.dart';
import 'statistic.dart';

class AdminHomePage extends StatefulWidget {
  AdminHomePage({Key? key}) : super(key: key);

  @override
  State<AdminHomePage> createState() => _AdminHomePage();
}

class _AdminHomePage extends State<AdminHomePage> {
  final PageController pageController = PageController(initialPage: 0);
  late int _selectedIndex = 0;
  final TextEditingController plan_name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Welcome Admin"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              // Navigator.of(context).pop();
            },
          ),
          //leading:
        ],
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => statistical_report(),
              ),
            );
          },
          child: Icon(Icons.bar_chart),
        ),
      ),
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return PlanNameAlert();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
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
        //   // Wrap the TextField and PageView in a Column
        children: [
          Expanded(
            // Use Expanded to make the PageView take remaining space
            child: PageView(
              controller: pageController,
              children: <Widget>[
                Center(
                  child: Plans(),
                ),
                // Center(
                //   child: Categories(),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
