import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:open_file/open_file.dart';

class statistical_report extends StatefulWidget {
  const statistical_report({super.key});

  @override
  State<statistical_report> createState() => _statistical_reportState();
}

class _statistical_reportState extends State<statistical_report> {
  late String filePath = '';

  Future<void> openFile(String filePath) async {
    try {
      print('hello');
      final result = await OpenFile.open(filePath);

      if (result.type == ResultType.done) {
        print('done');
        // The file was successfully opened with a third-party app.
      } else {
        // Handle other result types if needed.
      }
    } catch (e) {
      print('Error opening file: $e');
      // Handle any errors that occur during the process.
    }
  }

  Future<void> createExcelSheet(List<String> allData) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    final int itemsPerRow = 6;

    for (int i = 0; i < allData.length; i += itemsPerRow) {
      final List<String> row = allData.skip(i).take(itemsPerRow).toList();
      sheet.appendRow(row);
    }

    try {
      final Directory? directory = await getExternalStorageDirectory();
      final String excelFilePath = '${directory!.path}/example.xlsx';

      final file = File(excelFilePath);
      final excelData = await excel.encode();

      if (excelData != null) {
        await file.writeAsBytes(excelData);
        openFile(excelFilePath); // Open the Excel file
        print('Excel sheet created and saved to $excelFilePath');
      } else {
        print('Failed to create Excel sheet.');
      }
    } catch (e) {
      print('Error creating Excel file: $e');
    }
  }

  Future<void> fetchAllData() async {
    List<String> allData = [];
    allData.add('Plan');
    allData.add('Store');
    allData.add('Task Number');
    allData.add('End Date');
    allData.add('Status');
    allData.add('Upload Date');

    // Fetch your data from Firestore here and populate allData
    // Example: Fetch data from Firestore collections
    try {
      QuerySnapshot topCollectionSnapshot =
          await FirebaseFirestore.instance.collection('Plans').get();

      for (QueryDocumentSnapshot topDocumentSnapshot
          in topCollectionSnapshot.docs) {
        Map<String, dynamic> topDocumentData =
            topDocumentSnapshot.data() as Map<String, dynamic>;
        String PlanName = topDocumentData['PlanName'];

        QuerySnapshot nestedCollectionSnapshot = await FirebaseFirestore
            .instance
            .collection('Plans')
            .doc(topDocumentSnapshot.id)
            .collection('stores')
            .get();

        for (QueryDocumentSnapshot nestedDocumentSnapshot
            in nestedCollectionSnapshot.docs) {
          Map<String, dynamic> nestedDocumentData =
              nestedDocumentSnapshot.data() as Map<String, dynamic>;
          String StoreName = nestedDocumentData['StoreName'];

          QuerySnapshot nestednestedCollectionSnapshot = await FirebaseFirestore
              .instance
              .collection('Plans')
              .doc(topDocumentSnapshot.id)
              .collection('stores')
              .doc(nestedDocumentSnapshot.id)
              .collection('subcollection')
              .get();

          for (QueryDocumentSnapshot nestednestedDocumentSnapshot
              in nestednestedCollectionSnapshot.docs) {
            Map<String, dynamic> nestednestedDocumentData =
                nestednestedDocumentSnapshot.data() as Map<String, dynamic>;
            String TaskName = nestednestedDocumentData['Task'];
            bool Status = nestednestedDocumentData['isComplete'];
            Timestamp? timestamp = nestednestedDocumentData['End Date'];
            DateTime? dateTime = timestamp?.toDate();
            String formattedDate = dateTime != null
                ? DateFormat('yyyy-MM-dd').format(dateTime)
                : '';

            Timestamp? timestampupload =
                nestednestedDocumentData['upload_date'];
            DateTime? dateTimeupload = timestampupload?.toDate();
            String formattedDateupload = dateTimeupload != null
                ? DateFormat('yyyy-MM-dd').format(dateTimeupload)
                : '';

            allData.add(PlanName);
            allData.add(StoreName);
            allData.add(TaskName);
            allData.add(formattedDate);
            if (Status == true) {
              allData.add('Completed');
            } else if (Status == false) {
              allData.add('Pending');
            } else {
              allData.add(''); // Handle other cases here
            }
            allData.add(formattedDateupload);
          }
        }
      }
      print(allData);
      createExcelSheet(allData);
    } catch (e) {
      print('Error fetching data from Firestore: $e');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistical Report'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            fetchAllData();
          },
          child: Text('Generate Excel Sheet'),
        ),
      ),
    );
  }
}
