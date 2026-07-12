import 'package:flutter/material.dart';
import 'dart:async';
import 'screens/battery_screen.dart';      
import 'screens/placement_screen.dart';    
import 'screens/range_screen.dart';        

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inteli-Rehab Hub',
      home: const Scaffold(
        backgroundColor: Color(0xFFF1F5F9),
        body: SafeArea(
          child: Center(
            child: RangeScreen(), 
          ),
        ),
      ),
    );
  }
}

class CleanScreen extends StatefulWidget {
  const CleanScreen({super.key});

  @override
  State<CleanScreen> createState() => _CleanScreenState();
}

class _CleanScreenState extends State<CleanScreen> {
  int currentStep = 1;
  String searchStatus = 'idle'; // idle, scanning, success

  void handleDiagnosticScan() {
    setState(() {
      searchStatus = 'scanning';
      currentStep = 2;
    });

    Timer(const Duration(seconds: 2), () {
      setState(() {
        searchStatus = 'success';
        currentStep = 3;
      });
    });
  }

  void resetToStepOne() {
    setState(() {
      currentStep = 1;
      searchStatus = 'idle';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = searchStatus == 'success';
    final dotColor = isSuccess ? Colors.green : const Color(0xFF0C9E98);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 450), 
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEEF9F8), Color(0xFFF4FAFA), Color(0xFFF0F8F8)],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 📱 SYSTEM TOP BAR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('9:41', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
              Row(
                children: [
                  const Icon(Icons.bluetooth, size: 12, color: Color(0xFF0C9E98)),
                  const SizedBox(width: 4),
                  Container(
                    width: 20,
                    height: 10,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black38),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
                ],
              )
            ],
          ),
          const SizedBox(height: 8),

          // 📊 PROGRESS BAR
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('STEP $currentStep OF 3', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF0C9E98))),
                  Text(
                    currentStep == 1 ? 'Placement Diagnostics' : currentStep == 2 ? 'Device Health Check' : 'Verification Success',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black38),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 6,
                  color: const Color(0xFFD8ECEC),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: currentStep / 3.0,
                    child: Container(color: const Color(0xFF0C9E98)),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),

          // 🛑 HEADER NAVIGATION
          Row(
            children: [
              InkWell(
                onTap: resetToStepOne,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: const Icon(Icons.chevron_left, size: 18, color: Colors.black87),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('INTELI-REHAB', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Color(0xFF0C9E98))),
                    Text(
                      currentStep == 1 ? 'Placement Diagnostics Hub' : (searchStatus == 'scanning' ? 'Activating Sensor Cluster...' : 'Hardware Streams Approved'),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 12),

          // ═══ 🖼️ IMAGE WINDOW (NOW TRULY LOCKED - WILL NEVER RESIZE) ═══
          Center(
            child: Container(
              width: 380,
              height: 340, // Strict rigid sizing locks layout bounds completely
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.6)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final h = constraints.maxHeight;
                    final w = constraints.maxWidth;
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/arms-bg.png', 
                            fit: BoxFit.cover, // Ensures background canvas perfectly matches coordinate fields
                          ),
                        ),
                        if (searchStatus == 'scanning')
                          Container(color: const Color(0xFF0C9E98).withOpacity(0.05)),
                        
                        // Precise manual micro-coordinates pinned over target visuals
                        Positioned(top: h * 0.300, left: w * 0.190, child: buildDotMarker(dotColor)), // Biceps
                        Positioned(top: h * 0.660, left: w * 0.180, child: buildDotMarker(dotColor)), // Forearm
                        Positioned(top: h * 0.225, left: w * 0.776, child: buildDotMarker(dotColor)), // Upper IMU
                         // Triceps
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ═══ 📊 SCROLLABLE LABELS (THIS HANDLES LAYOUT GROWING/SHRINKING NOW) ═══
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pre-flight System Requirements', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                        const SizedBox(height: 6),
                        buildChecklistItem('All sensor batteries must be above the 20% limit'),
                        buildChecklistItem('Sensor placement should be accurate and aligned with the muscle'),
                        buildChecklistItem('Devices are supposed to be within the required 2-meter range'),
                      ],
                    ),
                  ),
                  
                  if (searchStatus == 'scanning')
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: const Row(
                        children: [
                          SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0C9E98))),
                          SizedBox(width: 10),
                          Expanded(child: Text('Sweeping Signal & Hardware Handshake Pins...', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))))
                        ],
                      ),
                    ),
                  
                  if (currentStep == 3)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5), 
                        borderRadius: BorderRadius.circular(12), 
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('✓ Device Connection Check Approved', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF065F46))),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(8)),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.battery_charging_full, size: 12, color: Color(0xFF0C9E98)),
                                    SizedBox(width: 4),
                                    Text('Average Battery: 96%', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                                  ],
                                ),
                                Text('Signal: Excellent', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF475569)))
                           ],
                        ),
                      )
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
          const SizedBox(height: 10),

          // ═══ 🚀 ACTION BUTTON FOOTER ═══
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: currentStep == 3 ? () {} : handleDiagnosticScan,
              style: ElevatedButton.styleFrom(
                backgroundColor: currentStep == 3 ? const Color(0xFF22C55E) : const Color(0xFF0C9E98),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (searchStatus == 'scanning')
                    const Padding(padding: EdgeInsets.only(right: 8.0), child: SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))),
                  Text(
                    currentStep == 1 ? 'Start Diagnostic Check' : (searchStatus == 'scanning' ? 'Validating Sensors...' : 'Proceed to Joint Calibration'),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildDotMarker(Color color) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
      ),
    );
  }

  Widget buildChecklistItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(6)),
        child: Row(
          children: [
            const Icon(Icons.power_settings_new_rounded, size: 11, color: Color(0xFF0C9E98)),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF475569)))),
          ],
        ),
      ),
    );
  }
}