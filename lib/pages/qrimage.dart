import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRImage extends StatelessWidget {
  const QRImage({super.key,required this.controller});
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('sometext'), centerTitle: true,),
    body: Center( child: QrImageView(
  data: controller.text,
  version: QrVersions.auto,
  size: 200.0,

    ),
    )
    
    );
  }
}
