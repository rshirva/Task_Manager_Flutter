import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlanNameAlert extends StatefulWidget {
  const PlanNameAlert({Key? key}) : super(key: key);

  @override
  State<PlanNameAlert> createState() => _PlanNameAlertState();
}

class _PlanNameAlertState extends State<PlanNameAlert> {
  final TextEditingController PlanNameController = TextEditingController();

  void _addStore(String PlanName) async {
    DocumentReference docRef =
        await FirebaseFirestore.instance.collection('Plans').add(
      {
        'PlanName': PlanName,
      },
    );
    print('Store added with ID: ${docRef.id}');
  }

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
        controller: PlanNameController,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          hintText: 'Plan Name',
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
            final PlanName = PlanNameController.text;
            _addStore(PlanName);
            Navigator.of(context).pop(); // Close the dialog after saving
          },
          child: const Text('Save'),
        ),
      ],
    );
  

  }
}
