// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:camera/camera.dart';
import 'package:task_manager/pages/UserHomepage.dart';
import 'package:task_manager/pages/view_image.dart';
import 'UserCamera_page.dart';
//import 'Display_Store_Page.dart';
//import 'package:task_manager/Alert_Dialogues/Task_AlertDialogue.dart';

class UserTask extends StatefulWidget {
  final String plan_name;
  final String store_name;
  final String? email;

  const UserTask(
      {Key? key,
      required this.plan_name,
      required this.store_name,
      required this.email})
      : super(key: key);

  @override
  State<UserTask> createState() => _UserTaskState(plan_name, store_name, email);
}

class _UserTaskState extends State<UserTask> {
  final PageController pageController = PageController(initialPage: 0);
  _UserTaskState(this.plan_name, this.store_name, this.email);

  late int _selectedIndex = 0;
  final String plan_name;
  final String store_name;
  final String? email;
  String? Planid; // Initialize as nullable String
  String? storeid; // Initialize as nullable String

  Future<void> getid() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Plans')
        .where("PlanName", isEqualTo: plan_name)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot planDoc = querySnapshot.docs[0];
      Planid = planDoc.id;
    }

    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('Plans')
        .doc(Planid) // This might be null, handle accordingly
        .collection('stores')
        .where('StoreName', isEqualTo: store_name)
        .get();

    if (query.docs.isNotEmpty) {
      DocumentSnapshot storedoc = query.docs[0];
      storeid = storedoc.id;
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
        title: Text("Tasks in $store_name"),
        //automaticallyImplyLeading: false,
        actions: <Widget>[
          Hero(
            tag: 'unique_tag_for_user_task',
            child: IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => UserHomePage(email: email)));
              },
              icon: const Icon(Icons.house_outlined),
            ),
          ),
        ],
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          // Page 1: Store List
          buildTaskListPage(),

          //Page 2: Add Tasks
          PendingTaskPage(),
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
                label: 'Task List',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.pending_actions_sharp),
                label: 'Pending',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTaskListPage() {
    if (Planid != null && storeid != null) {
      return Scaffold(
        body: Container(
          margin: const EdgeInsets.all(10.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Plans/$Planid/stores/$storeid/subcollection')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print('Data: ${snapshot.data!.docs.length} documents');
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No tasks to display'),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = snapshot.data!.docs[index];
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      DateTime endDate =
                          (data['End Date'] as Timestamp).toDate();
                      String formattedEndDate =
                          DateFormat('yyyy-MM-dd').format(endDate);

                      return Container(
                        height: 80,
                        margin: const EdgeInsets.only(bottom: 15.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: const Color.fromARGB(255, 223, 235, 245),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 5.0,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ListTile(
                          //isThreeLine: true,
                          title: Row(children: <Widget>[
                            //Icon(Icons.circle),
                            Text(
                              data['Task'],
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(
                              'Due Date: $formattedEndDate',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ]),
                          subtitle: Row(children: <Widget>[
                            Container(
                              child: data['image_url'] == ''
                                  ? const Icon(
                                      Icons.circle,
                                      color: Colors.red,
                                    )
                                  : const Icon(
                                      Icons.circle,
                                      color: Colors.green,
                                    ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Container(
                              child: data['image_url'] == ''
                                  ? Row(children: <Widget>[
                                      // FloatingActionButton(
                                      //   onPressed: () {},
                                      //   child: Icon(Icons.image),
                                      //   mini: true,
                                      // ),
                                      // SizedBox(
                                      //   width: 10,
                                      // ),
                                      const Text('Task Incomplete'),
                                    ])
                                  : Row(children: <Widget>[
                                      Hero(
                                        tag: 'view_image' + data['Task'],
                                        child: FloatingActionButton(
                                          heroTag: null,
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) => image_view(
                                                        url: data[
                                                            'image_url'])));
                                          },
                                          child: Icon(Icons.image),
                                          mini: true,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      const Text('Image uploaded'),
                                    ]),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Hero(
                              tag: 'Camera_click_' + data['Task'],
                              child: FloatingActionButton(
                                heroTag: null,
                                onPressed: () async {
                                  await availableCameras().then((value) =>
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => CameraPage(
                                                  cameras: value,
                                                  plan_name: plan_name,
                                                  store_name: store_name,
                                                  name: data['Task'],
                                                  email: email))));
                                },
                                mini: true,
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                ),
                              ),
                            ),
                          ]),
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
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      );
    } else {
      // Return a loading indicator or an appropriate message
      return const Center(
        child: Text('Click the button below to view tasks'),
      );
    }
  }

  Widget PendingTaskPage() {
    if (Planid != null && storeid != null) {
      return Scaffold(
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Plans/$Planid/stores/$storeid/subcollection')
              .where('isComplete', isEqualTo: false)
              .orderBy('End Date', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('An error occurred: ${snapshot.error}'),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No pending tasks to display'),
              );
            }

            // Extract ordered data
            final orderedData = snapshot.data!.docs;

            return ListView.builder(
              itemCount: orderedData.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = orderedData[index];
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                DateTime endDate = (data['End Date'] as Timestamp).toDate();
                String formattedEndDate =
                    DateFormat('yyyy-MM-dd').format(endDate);

                return Container(
                  height: 80,
                  margin: const EdgeInsets.only(bottom: 15.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: const Color.fromARGB(255, 223, 235, 245),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 5.0,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ListTile(
                    //isThreeLine: true,
                    title: Row(children: <Widget>[
                      //Icon(Icons.circle),
                      Text(
                        data['Task'],
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        'Due Date: $formattedEndDate',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ]),
                    subtitle: Row(children: <Widget>[
                      Container(
                        child: data['image_url'] == ''
                            ? const Icon(
                                Icons.circle,
                                color: Colors.red,
                              )
                            : const Icon(
                                Icons.circle,
                                color: Colors.green,
                              ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        child: data['image_url'] == ''
                            ? Row(children: <Widget>[
                                // FloatingActionButton(
                                //   onPressed: () {},
                                //   child: Icon(Icons.image),
                                //   mini: true,
                                // ),
                                SizedBox(
                                  width: 10,
                                ),
                                const Text('Task Incomplete'),
                              ])
                            : Row(children: <Widget>[
                                Hero(
                                  tag: 'view_image' + data['Task'],
                                  child: FloatingActionButton(
                                    heroTag: null,
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => image_view(
                                                  url: data['image_url'])));
                                    },
                                    child: Icon(Icons.image),
                                    mini: true,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                const Text('Image uploaded'),
                              ]),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Hero(
                        tag: 'Camera_click_x' + data['Task'],
                        child: FloatingActionButton(
                          heroTag: null,
                          onPressed: () async {
                            await availableCameras().then((value) =>
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => CameraPage(
                                            cameras: value,
                                            plan_name: plan_name,
                                            store_name: store_name,
                                            name: data['Task'],
                                            email: email))));
                          },
                          mini: true,
                          child: const Icon(
                            Icons.camera_alt_outlined,
                          ),
                        ),
                      ),
                    ]),
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
          },
        ),
      );
    } else {
      // Return a loading indicator or an appropriate message
      return const Center(
        child: Text('Click the button below to view pending tasks'),
      );
    }
  }
}
