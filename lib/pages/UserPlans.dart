import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'UserTask.dart';

class UserPlans extends StatefulWidget {
  UserPlans({Key? key, required this.email}) : super(key: key);
  final String? email;

  @override
  State<UserPlans> createState() => _UserPlansState(email);
}

class _UserPlansState extends State<UserPlans> {
  final String? email;

  _UserPlansState(this.email);

  Future<String> getDesignation() async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('Users')
        .where('email', isEqualTo: email)
        .get();
    if (query.docs.isNotEmpty) {
      DocumentSnapshot doc = query.docs[0];
      return doc['Designation'];
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<String>(
        future: getDesignation(),
        builder: (context, designationSnapshot) {
          if (designationSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (designationSnapshot.hasError) {
            return Center(child: Text('Error: ${designationSnapshot.error}'));
          }

          final String designation = designationSnapshot.data ?? '';

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Plans').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No data available'));
              }

              final subcollectionQueries = snapshot.data!.docs.map((doc) {
                final subcollection = doc.reference.collection('stores');
                return subcollection
                    .where('StoreName', isEqualTo: designation)
                    .get();
              }).toList();

              return FutureBuilder<List<QuerySnapshot>>(
                future: Future.wait(subcollectionQueries),
                builder: (context, subSnapshots) {
                  if (subSnapshots.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  List<Widget> matchingDocuments = [];

                  for (int i = 0; i < snapshot.data!.docs.length; i++) {
                    final subSnapshot = subSnapshots.data![i];
                    final doc = snapshot.data!.docs[i];

                    if (subSnapshot.docs.isNotEmpty) {
                      matchingDocuments.add(
                        Card(
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          margin: const EdgeInsets.all(10.0),
                          color: Color.fromARGB(255, 151, 205, 248),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserTask(
                                      plan_name: doc['PlanName'],
                                      store_name: designation,
                                      email: email),
                                ),
                              );
                            },
                            child: ListTile(
                              title: Text(doc['PlanName']),
                              trailing: Icon(Icons.arrow_forward),
                            ),
                          ),
                        ),
                      );
                    }
                  }

                  if (matchingDocuments.isEmpty) {
                    return Center(child: Text('No matching documents found.'));
                  }

                  return ListView.builder(
                    itemCount: matchingDocuments.length,
                    itemBuilder: (BuildContext context, int index) {
                      return matchingDocuments[index];
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
