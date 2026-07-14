import 'package:flutter/material.dart';
import 'package:inteli_rehab/core/constants/app_colors.dart';
import 'package:inteli_rehab/core/globals.dart';

class DigitalTwinScreen extends StatelessWidget {
  const DigitalTwinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Digital Twin', style: TextStyle(color: Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Image.asset('assets/images/logo.png', width: 28, height: 28),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
            },
          ),
          if (globalIsDeviceConnected)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(
                child: Row(
                  children: [
                    Icon(Icons.bluetooth_connected, color: AppColors.tealCore, size: 18),
                    SizedBox(width: 4),
                    Text('Connected', style: TextStyle(color: AppColors.tealCore, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.accessibility_new_rounded, size: 120, color: AppColors.tealCore.withValues(alpha: 0.5)),
            const SizedBox(height: 24),
            const Text(
              'Digital Twin Active',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Real-time 3D modeling of your posture and muscle strain is currently active. Device sensor data is being synced.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
