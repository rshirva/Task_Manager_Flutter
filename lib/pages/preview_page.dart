import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'UserTask.dart';
//import 'Display_Tasks_page.dart';

class PreviewPage extends StatefulWidget {
  final String plan_name;
  final String store_name;
  final String name;
  final XFile picture;
  final String? email;

  PreviewPage(
      {Key? key,
      required this.picture,
      required this.plan_name,
      required this.store_name,
      required this.name,
      required this.email})
      : super(key: key);

  @override
  _PreviewPageState createState() =>
      _PreviewPageState(plan_name, store_name, picture, name, email);
}

class _PreviewPageState extends State<PreviewPage> {
  late String downloadurl;
  late String Planid;
  late String storeid;
  final String plan_name;
  final String store_name;
  final String name;
  late String taskid;
  final XFile picture;
  final String? email;
  _PreviewPageState(
      this.plan_name, this.store_name, this.picture, this.name, this.email);

  @override
  void initState() {
    super.initState();
    getIds();
  }

  Future<void> uploadImage(File jpgFile) async {
    try {
      final fileName = path.basename(jpgFile.path);
      final Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('images/$fileName');

      final UploadTask uploadTask = firebaseStorageRef.putFile(jpgFile);

      await uploadTask.whenComplete(() async {
        final imageUrl = await firebaseStorageRef.getDownloadURL();
        downloadurl = imageUrl;
        print('JPG file uploaded to Firebase Storage. URL: $imageUrl');
        addDataToFirestore(imageUrl);
      });
    } catch (error) {
      print('Error uploading JPG file: $error');
    }
  }

  Future<void> getIds() async {
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
        .doc(Planid)
        .collection('stores')
        .where('StoreName', isEqualTo: store_name)
        .get();

    if (query.docs.isNotEmpty) {
      DocumentSnapshot storedoc = query.docs[0];
      storeid = storedoc.id;
    }

    QuerySnapshot query_task = await FirebaseFirestore.instance
        .collection('Plans')
        .doc(Planid)
        .collection('stores')
        .doc(storeid)
        .collection('subcollection')
        .where('Task', isEqualTo: name)
        .get();

    if (query_task.docs.isNotEmpty) {
      DocumentSnapshot taskdoc = query_task.docs[0];
      taskid = taskdoc.id;
    }
  }

  void addDataToFirestore(String imageUrl) async {
    // Assuming you have a reference to the document you want to update
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('Plans')
        .doc(Planid)
        .collection('stores')
        .doc(storeid)
        .collection('subcollection')
        .doc(taskid);

    // Get the current date and time
    Timestamp currentTime = Timestamp.now();

    // Create a map with the field you want to update and its new value
    Map<String, dynamic> updatedData = {
      'image_url': imageUrl,
      'upload_date': currentTime, // Store the timestamp
      'isComplete': true,
    };

    try {
      // Update the document with the new data
      await docRef.update(updatedData);
      print('Document successfully updated with new URL and timestamp');
    } catch (error) {
      print('Error updating document: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Page')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Image.file(File(widget.picture.path), fit: BoxFit.cover, width: 250),
          const SizedBox(height: 24),
          Text(widget.picture.name),
          Row(children: <Widget>[
            SizedBox(width: 120),
            ElevatedButton(
                onPressed: () {
                  File jpgFile = File(widget.picture.path);
                  uploadImage(jpgFile);
                },
                child: Text('Upload')),
            SizedBox(width: 30),
            ElevatedButton(
                onPressed: () {
                  //Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => UserTask(
                              plan_name: plan_name,
                              store_name: store_name,
                              email: email)));
                }, // Go back to the previous screen
                //},
                child: Text('Exit'))
          ]),
        ]),
      ),
    );
  }
}
