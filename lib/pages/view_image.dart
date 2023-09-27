import 'package:flutter/material.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

class image_view extends StatefulWidget {
  image_view({super.key, required this.url});
  final String url;

  @override
  State<image_view> createState() => _image_viewState(url);
}

class _image_viewState extends State<image_view> {
  final String url;

  _image_viewState(this.url);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Uploaded Image'),
      ),
      body: Image.network(
        url, // Provide the image URL here
        width: 300, // Set the width to your desired size
        height: 500, // Set the height to your desired size
        fit: BoxFit.cover, // Adjust the fit as needed
      ),
    );
  }
}
