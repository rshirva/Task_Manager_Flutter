//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:task_manager/pages/home.dart';

class StoreAlert extends StatefulWidget {
  final String nextpg;
  const StoreAlert({super.key, required this.nextpg});

  @override
  State<StoreAlert> createState() => _StoreAlertState(nextpg);
}

class _StoreAlertState extends State<StoreAlert> {
  final TextEditingController StoreNameAlert = TextEditingController();
  final String nextpg;
  _StoreAlertState(this.nextpg);

  void _addStore(String StoreName) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('Plans')
      .where("PlanName", isEqualTo: nextpg) // Use the variable 'nextpg' instead of the string "nextpg"
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    DocumentSnapshot planDoc = querySnapshot.docs[0];
    String planId = planDoc.id;
    await FirebaseFirestore.instance.collection('Plans/$planId/stores').add({
      'StoreName': StoreName,
    });
  }
}

    //print('Store added with ID: ${docRef.id}');


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: const Text(
        'New Plan',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16.0, color: Colors.brown),
      ),
      content: TextField(
        controller: StoreNameAlert,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          hintText: 'Store Name $nextpg',
          hintStyle: const TextStyle(fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog without saving
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final StoreName = StoreNameAlert.text;
            _addStore(StoreName);
            Navigator.of(context).pop(); // Close the dialog after saving
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
