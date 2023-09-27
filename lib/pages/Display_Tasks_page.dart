import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/pages/view_image.dart';
import 'Display_Store_Page.dart';
import 'dart:io';
import 'dart:typed_data'; // Add this import for Uint8List
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class TaskDisplay extends StatefulWidget {
  final String name;
  final String store_name;

  const TaskDisplay({Key? key, required this.name, required this.store_name})
      : super(key: key);

  @override
  State<TaskDisplay> createState() => _TaskDisplayState(name, store_name);
}

class _TaskDisplayState extends State<TaskDisplay> {
  final PageController pageController = PageController(initialPage: 0);
  _TaskDisplayState(this.name, this.store_name);

  late int _selectedIndex = 0;
  final String name;
  final String store_name;
  String? Planid; // Initialize as nullable String
  String? storeid; // Initialize as nullable String
  bool _permissionGranted = false;

  void requestPermission() async {
    final status = await Permission.photos.request();
    if (status.isGranted) {
      setState(() {
        _permissionGranted = true;
      });
    } else {
      setState(() {
        _permissionGranted = false;
      });
    }
  }

  Future<void> downloadAndSaveImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        // Save the image to the gallery
        final result = await ImageGallerySaver.saveImage(
            Uint8List.fromList(response.bodyBytes));

        if (result != null && result['isSuccess'] == true) {
          // Image saved successfully
          print('Image saved to gallery.');
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Image Downloaded'),
              content: Text(
                  'The image has been downloaded and saved to your device\'s gallery.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        } else {
          // Failed to save the image
          print('Failed to save the image.');
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Failed to download Image'),
              content:
                  Text('The image could not be downloaded to your device.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        // Handle HTTP request errors
        print(
            'Error Failed to download the image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any exceptions that may occur
      print('Error: $e');
    }
  }

  Future<void> getid() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Plans')
        .where("PlanName", isEqualTo: name)
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
    requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Tasks in $store_name"),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          Hero(
            tag: 'unique_tag_for_Admin_$name',
            child: IconButton(
              //heroTag: null,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => NextPage(name: name)));
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
          buildAddTasksPage(),
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
                icon: Icon(Icons.add),
                label: 'Add Tasks',
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
                .orderBy('isComplete', descending: false)
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
                                      //data['isComplete'] = true;
                                    ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Container(
                              child: data['image_url'] == ''
                                  ? Row(children: <Widget>[
                                      SizedBox(
                                        width: 10,
                                      ),
                                      const Text('Task Incomplete'),
                                    ])
                                  : Row(children: <Widget>[
                                      Hero(
                                        // ignore: prefer_interpolation_to_compose_strings
                                        tag: 'view_image' +
                                            data['Task'] +
                                            '_Admin',
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
                                      Hero(
                                        tag: 'download_image' + data['Task'],
                                        child: FloatingActionButton(
                                          heroTag: null,
                                          onPressed: () {
                                            downloadAndSaveImage(
                                                data['image_url']);
                                          },
                                          child: Icon(
                                              Icons.download_for_offline_sharp),
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

  Widget buildAddTasksPage() {
    // Replace with the content of your "Add Tasks" page
    return Scaffold();
  }
}
