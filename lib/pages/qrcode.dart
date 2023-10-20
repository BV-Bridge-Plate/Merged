import 'package:ipfs/pages/qrimage.dart';
import 'package:ipfs/pages/qrscanner.dart';
import 'package:flutter/material.dart';

class QRCode extends StatefulWidget {
  const QRCode({super.key});

  @override
  State<QRCode> createState() => _QRCodeState();
}

class _QRCodeState extends State<QRCode> {
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("some"),
          centerTitle: true,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.all(20),
              child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter your URL')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => QRImage(controller: controller)));
              },
              child: const Text('Generate'),
            ),
            ElevatedButton(onPressed: () {Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => QRScanner()));}, child: const Text('Scan')),
          ],
        ));
  }
}
