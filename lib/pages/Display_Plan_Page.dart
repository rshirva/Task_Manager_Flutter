import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'Display_Store_Page.dart';

class Plans extends StatefulWidget {
  Plans({Key? key}) : super(key: key);
  //final String name;
  @override
  State<Plans> createState() => _PlansState();
}

class _PlansState extends State<Plans> {
  //final String name;
  //_PlansState(this.name);
  final fireStore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(10.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: fireStore.collection('Plans').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text('No stores to display');
            } else {
              return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  //Color taskColor = Colors.white;
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
                        'Plan - ' + data['PlanName'],
                        style: const TextStyle(fontSize: 20),
                      ),
                      subtitle: Row(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      NextPage(name: data['PlanName']),
                                ),
                              );
                            },
                            child: Icon(Icons.arrow_forward),
                          )
                        ],
                      ),

                      //subtitle: Text(data['taskDesc']),
                      //isThreeLine: true,
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
                }).toList(),
              );
            }
          },
        ),
      ),
    );
  }
}
