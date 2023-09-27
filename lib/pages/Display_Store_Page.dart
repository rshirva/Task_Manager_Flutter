import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/pages/home.dart';
import '../Alert_Dialogues/Store_AlertDialogue.dart';
import '../Alert_Dialogues/Task_AlertDialogue.dart';
import 'Display_Tasks_page.dart';

class NextPage extends StatefulWidget {
  final String name;

  const NextPage({Key? key, required this.name}) : super(key: key);

  @override
  State<NextPage> createState() => _NextPageState(name);
}

class _NextPageState extends State<NextPage> {
  final PageController pageController = PageController(initialPage: 0);
  _NextPageState(this.name);

  late int _selectedIndex = 0;
  final String name;
  late String Planid = ' ';

  Future<void> getid() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Plans')
        .where("PlanName", isEqualTo: name)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot planDoc = querySnapshot.docs[0];
      Planid = planDoc.id;
    }
  }

  @override
  void initState() {
    super.initState();
    getid();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Stores"),
        actions: <Widget>[
          Hero(
            tag: 'unique tag for icon button',
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AdminHomePage(),
                  ),
                );
              },
              icon: const Icon(Icons.house_outlined),
            ),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: PageView(
        controller: pageController,
        children: <Widget>[
          // Page 1: Store List
          StoreList(Planid: Planid, name: name),

          // Page 2: Add Store
          AddTaskWidget(name: name),
        ],
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
                icon: Icon(Icons.list),
                label: 'Store List', // Label for Page 1
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add),
                label: 'Add Tasks', // Label for Page 2
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class StoreList extends StatelessWidget {
  final String Planid;
  final String name;
  late String storename;
  final TextEditingController s_name = TextEditingController();

  StoreList({Key? key, required this.Planid, required this.name})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(10),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Plans/$Planid/stores')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text('No stores to display');
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = snapshot.data!.docs[index];
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      return Card(
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              15.0), // Adjust the border radius as needed
                        ),

                        //height: 80,
                        margin: const EdgeInsets.only(bottom: 15.0),
                        color: Color.fromARGB(255, 151, 205, 248),
                        child: ListTile(
                          title: Text(
                            'Store - ' + data['StoreName'],
                            style: const TextStyle(fontSize: 20),
                          ),
                          subtitle: Row(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TaskDisplay(
                                          name: name,
                                          store_name: data['StoreName']),
                                    ),
                                  );
                                },
                                child: Icon(Icons.arrow_forward),
                              )
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) {
                              return [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: const Text(
                                    'Edit',
                                    style: TextStyle(fontSize: 13.0),
                                  ),
                                  onTap: () {},
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(fontSize: 13.0),
                                  ),
                                  onTap: () {},
                                ),
                              ];
                            },
                          ),
                          dense: true,
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Hero(
            tag:
                'add_store_${name}_dialog', // Unique hero tag for the dialog FAB
            child: FloatingActionButton(
              heroTag: null,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return StoreAlert(nextpg: name);
                  },
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}

class AddTaskWidget extends StatelessWidget {
  final String name;

  const AddTaskWidget({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Add tasks for Plan: $name"),
      ),
      floatingActionButton: Hero(
        tag: 'task_add_all',
        child: FloatingActionButton(
          heroTag: null,
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return TaskAlert(planname: name);
              },
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
