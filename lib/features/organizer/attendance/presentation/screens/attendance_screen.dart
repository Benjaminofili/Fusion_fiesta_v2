import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AttendanceScreen extends StatelessWidget {
  AttendanceScreen({super.key});

  final MobileScannerController _controller = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Attendance')),
      body: Column(
        children: [
          Expanded(child: MobileScanner(controller: _controller)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
                onPressed: () {},
                child: const Text('Mark Attendance Manually')),
          ),
        ],
      ),
    );
  }
}

