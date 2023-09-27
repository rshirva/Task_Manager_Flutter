// ignore_for_file: use_build_context_synchronously

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'preview_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage(
      {Key? key,
      required this.cameras,
      required this.plan_name,
      required this.store_name,
      required this.name,
      required this.email})
      : super(key: key);

  final List<CameraDescription>? cameras;
  final String plan_name;
  final String store_name;
  final String name;
  final String? email;

  @override
  State<CameraPage> createState() =>
      _CameraPageState(plan_name, store_name, name, email);
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  //_CameraPageState(plan_name, store_name, name);
  late String plan_name;
  late String store_name;
  late String name;
  final String? email;
  _CameraPageState(this.plan_name, this.store_name, this.name, this.email);

  //final bool _isRearCameraSelected = true;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initCamera(widget.cameras![0]);
  }

  Future<void> takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return;
    }
    if (_cameraController.value.isTakingPicture) {
      return;
    }
    try {
      await _cameraController.setFlashMode(FlashMode.off);
      XFile picture = await _cameraController.takePicture();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewPage(
              picture: picture,
              plan_name: plan_name,
              store_name: store_name,
              name: name,
              email: email),
        ),
      );
    } on CameraException catch (e) {
      debugPrint('Error occurred while taking picture: $e');
      return;
    }
  }

  Future<void> initCamera(CameraDescription cameraDescription) async {
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);
    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("Camera error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            (_cameraController.value.isInitialized)
                ? CameraPreview(_cameraController)
                : Container(
                    color: Colors.black,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.20,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  color: Colors.black,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Hero(
                        tag: 'camera_button_1', // Unique tag
                        child: FloatingActionButton(
                          heroTag: null,
                          onPressed: takePicture,
                          //iconSize: 50,
                          //padding: EdgeInsets.zero,
                          //constraints: const BoxConstraints(),
                          child: const Icon(Icons.circle, color: Colors.white),
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
