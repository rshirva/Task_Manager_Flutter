import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:task_manager/pages/Display_Store_Page.dart';

class TaskAlert extends StatefulWidget {
  final String planname;
  const TaskAlert({super.key, required this.planname});

  @override
  State<TaskAlert> createState() => _TaskAlertState(planname);
}

class _TaskAlertState extends State<TaskAlert> {
  final TextEditingController TaskNameController = TextEditingController();
  //final TextEditingController Date = TextEditingController();
  DateTime date = DateTime(2022, 12, 23);

  final String planname;
  late String planId = ' ';
  _TaskAlertState(this.planname);

  void _addTask(String Task, DateTime Date) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference plansCollection = firestore.collection('Plans');

    // Step 2: Retrieve the target documents (for example, based on a specific condition)
    final QuerySnapshot querySnapshot = await plansCollection
        .where('PlanName', isEqualTo: planname) // Customize the condition
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      planId = querySnapshot.docs[0].id;
    }

    final QuerySnapshot query = await FirebaseFirestore.instance
        .collection('Plans')
        .doc(planId)
        .collection('stores')
        .get();

    for (final QueryDocumentSnapshot doc in query.docs) {
      final Map<String, dynamic> subcollectionData = {
        'Task': Task,
        'End Date': Date,
        'image_url': '',
        'isComplete': false,
        'upload_date': null,
      };

      await doc.reference.collection('subcollection').add(subcollectionData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: const Text(
        'New Task',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16.0, color: Colors.brown),
      ),
      content: Column(
        children: <Widget>[
          TextField(
            controller: TaskNameController,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              hintText: 'Task Name',
              hintStyle: const TextStyle(fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: <Widget>[
              //Container(
              Text('${date.year}/${date.month}/${date.day}'),
              const SizedBox(
                width: 30,
              ),
              ElevatedButton(
                child: const Text('Select End Date'),
                onPressed: () async {
                  DateTime? newDate = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (newDate == null) {
                    return;
                  } else {
                    setState(() => date = newDate);
                  }
                },
              ),
              //),
            ],
            //)
            //]
          ),
        ],
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
            final Task = TaskNameController.text;
            //final Dates = Date.text;
            _addTask(Task, date);
            Navigator.of(context).pop(); // Close the dialog after saving
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
