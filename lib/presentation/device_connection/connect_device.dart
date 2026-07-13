import 'package:flutter/material.dart';
import 'dart:async';
import 'package:inteli_rehab/presentation/device_connection/bluetooth_permission.dart';

class PlacementScreen extends StatefulWidget {
  const PlacementScreen({super.key});

  @override
  State<PlacementScreen> createState() => _PlacementScreenState();
}

class _PlacementScreenState extends State<PlacementScreen> {
  int currentStep = 1;
  String searchStatus = 'idle'; // idle, scanning, warning, success

  void handleDiagnosticScan() {
    setState(() {
      searchStatus = 'scanning';
      currentStep = 2;
    });

    // Simulates background spatial evaluation failing after 2 seconds
    Timer(const Duration(seconds: 2), () {
      setState(() {
        searchStatus = 'warning';
      });
    });
  }

  void handleRetryScan() {
    setState(() {
      searchStatus = 'scanning';
    });
    // Simulates manual realignment success
    Timer(const Duration(milliseconds: 1500), () {
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
    final isIdle = searchStatus == 'idle';
    final isScanning = searchStatus == 'scanning';
    final isWarning = searchStatus == 'warning';
    final isSuccess = searchStatus == 'success';
    
    // Forearm IMU turns Amber if there is a warning, Green if success, Teal if scanning/idle
    final forearmColor = isWarning ? const Color(0xFFD97706) : (isSuccess ? Colors.green : const Color(0xFF0C9E98));
    final restColor = isSuccess ? Colors.green : const Color(0xFF0C9E98);

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
          const SizedBox(height: 6),

          // 📊 PROGRESS BAR
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('STEP $currentStep OF 3', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: isWarning ? const Color(0xFFD97706) : const Color(0xFF0C9E98))),
                  Text(
                    currentStep == 1 ? 'Placement Diagnostics' : (isWarning ? 'Calibration Warning' : 'Verification Success'),
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
                    child: Container(color: isWarning ? const Color(0xFFD97706) : const Color(0xFF0C9E98)),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),

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
                      isWarning ? 'Muscle Alignment Deviation' : (isScanning ? 'Activating Sensor Cluster...' : 'Hardware Streams Approved'),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 10),

          // ═══ 🖼️ IMAGE CANVAS WINDOW ═══
          Center(
            child: Container(
              width: 380,
              height: 340, 
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
                            'assets/images/arms-bg.png', 
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (isScanning)
                          Container(color: const Color(0xFF0C9E98).withOpacity(0.05)),
                        
                        Positioned(top: h * 0.300, left: w * 0.190, child: buildDotMarker(restColor)), 
                        Positioned(top: h * 0.660, left: w * 0.180, child: buildDotMarker(forearmColor)), // Dynamic Forearm Target Node
                        Positioned(top: h * 0.225, left: w * 0.776, child: buildDotMarker(restColor)), 
                        
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ═══ 📊 COMPACT SMART SWAPPING MODULE ═══
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // CONDITION 1: Idle Checklist (Ultra-tight Padding)
                if (isIdle)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pre-flight System Requirements', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                        const SizedBox(height: 4),
                        buildChecklistItem('All sensor batteries must be above the 20% limit'),
                        buildChecklistItem('Sensor placement should be accurate and aligned with the muscle'),
                        buildChecklistItem('Devices are supposed to be working within the required 2-meter range'),
                      ],
                    ),
                  ),
                
                // CONDITION 2: Active Scanning Layout
                if (isScanning)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Row(
                      children: [
                        Spacer(),
                        SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0C9E98))),
                        SizedBox(width: 10),
                        Expanded(child: Text('Sweeping Signal & Hardware Handshake Pins...', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                        Spacer(),
                      ],
                    ),
                  ),
                
                // CONDITION 3: Muscle Displacement Alert Card
                if (isWarning)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED), 
                      borderRadius: BorderRadius.circular(12), 
                      border: Border.all(color: const Color(0xFFFFEDD5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.error_outline_rounded, size: 13, color: Color(0xFFD97706)),
                            SizedBox(width: 4),
                            Text('Forearm IMU Displacement Alert', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text('The sensor has drifted from the targeted brachioradialis muscle center point parameters. Realign the strap boundary.', style: TextStyle(fontSize: 10, color: Color(0xFF9A3412))),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 26,
                          child: ElevatedButton.icon(
                            onPressed: handleRetryScan,
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706), padding: const EdgeInsets.symmetric(horizontal: 8), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                            icon: const Icon(Icons.cached, size: 11, color: Colors.white),
                            label: const Text('Re-evaluate Spatial Coordinates', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        )
                      ],
                    ),
                  ),

                // CONDITION 4: Verification Approved Card
                if (isSuccess)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5), 
                      borderRadius: BorderRadius.circular(12), 
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('✓ Device Connection Check Approved', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF065F46))),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(8)),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.battery_charging_full, size: 11, color: Color(0xFF0C9E98)),
                                  SizedBox(width: 4),
                                  Text('Average Battery: 96%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                                ],
                              ),
                              Text('Signal: Excellent', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF475569)))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: isSuccess 
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(
                              backgroundColor: const Color(0xFFEEF9F8),
                              elevation: 0,
                              leading: IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              title: const Text(
                                "BATTERY STATUS",
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: Colors.black54),
                              ),
                              centerTitle: true,
                            ),
                            body: const SafeArea(child: BatteryScreen()),
                          ),
                        ),
                      );
                    }
                  : (isWarning ? resetToStepOne : handleDiagnosticScan),
              style: ElevatedButton.styleFrom(
                backgroundColor: isWarning ? const Color(0xFF1E293B) : (isSuccess ? const Color(0xFF22C55E) : const Color(0xFF0C9E98)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                isWarning ? 'Reset Placement Target' : (isSuccess ? 'Proceed to Battery Check' : 'Start Diagnostic Check'),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
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
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(6)),
        child: Row(
          children: [
            const Icon(Icons.power_settings_new_rounded, size: 10, color: Color(0xFF0C9E98)),
            const SizedBox(width: 6),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w500, color: Color(0xFF475569)))),
          ],
        ),
      ),
    );
  }
}