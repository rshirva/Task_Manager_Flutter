// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_xlsio/xlsio.dart';
// import 'dart:typed_data';

// class ExcelViewer extends StatefulWidget {
//   final String filePath; // Provide the path to the Excel file

//   ExcelViewer({required this.filePath});

//   @override
//   _ExcelViewerState createState() => _ExcelViewerState();
// }

// class _ExcelViewerState extends State<ExcelViewer> {
//   late Workbook _workbook;

//   @override
//   void initState() {
//     super.initState();
//     _loadExcelFile();
//   }

//   Future<void> _loadExcelFile() async {
//     // Load the Excel file from the provided path
//     final ByteData data = await rootBundle.load(widget.filePath);
//     final List<int> bytes = data.buffer.asUint8List();
//     _workbook = Workbook.decodeBytes(Uint8List.fromList(bytes));

//     setState(() {
//       // Trigger a rebuild to display the Excel data
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Excel Viewer'),
//       ),
//       body: _workbook == null
//           ? Center(
//               child: CircularProgressIndicator(),
//             )
//           : SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.vertical,
//                 child: Container(
//                   padding: EdgeInsets.all(16.0),
//                   child: ExcelGrid(
//                     gridState: GridState(
//                       scrollBars: ScrollBars.both,
//                     ),
//                     workbook: _workbook,
//                     allowEditing: false,
//                     allowScrolling: true,
//                     showSheetTabs: false,
//                     onCellTap: (args) {
//                       // Handle cell tap events if needed
//                     },
//                   ),
//                 ),
//               ),
//             ),
//     );
//   }
// }
