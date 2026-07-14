import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inteli_rehab/core/constants/app_colors.dart';
import 'package:inteli_rehab/core/globals.dart';
import 'package:inteli_rehab/widgets/shared_widgets.dart';
import 'package:inteli_rehab/presentation/exercises/exercise_list.dart';

enum _BleState { idle, scanning, found, connecting, connected }

class _Device {
  final String name, signal;
  final IconData icon;
  _Device(this.name, this.signal, this.icon);
}

class ConnectDeviceScreen extends StatefulWidget {
  const ConnectDeviceScreen({super.key});

  @override
  State<ConnectDeviceScreen> createState() => _ConnectDeviceScreenState();
}

class _ConnectDeviceScreenState extends State<ConnectDeviceScreen> with TickerProviderStateMixin {
  _BleState _state = _BleState.idle;
  late AnimationController _scanPulse, _connPulse;
  int? _connecting;

  final _devices = [
    _Device('InteliRehab Band X1', 'Signal: Strong', Icons.watch_rounded),
    _Device('InteliRehab Band X1', 'Signal: Moderate', Icons.watch_rounded),
    _Device('InteliRehab Sensor v2', 'Signal: Strong', Icons.sensors_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _scanPulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _connPulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanPulse.dispose();
    _connPulse.dispose();
    super.dispose();
  }

  void _startScan() {
    setState(() => _state = _BleState.scanning);
    Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _state = _BleState.found);
    });
  }

  void _connect(int index) async {
    setState(() { _state = _BleState.connecting; _connecting = index; });
    await Future.delayed(const Duration(seconds: 2));
    globalIsDeviceConnected = true;
    if (mounted) setState(() => _state = _BleState.connected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.slate800),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Connect Devices', style: TextStyle(color: AppColors.slate800, fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Connect your wearable', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.slate800)),
              const SizedBox(height: 6),
              const Text('Make sure your InteliRehab armband is charged and within range', style: TextStyle(fontSize: 13, color: AppColors.slate400)),
              const SizedBox(height: 24),

              // Animated BLE visual
              Center(child: _BleVisual(state: _state, pulseCtrl: _scanPulse)),
              const SizedBox(height: 28),

              // Status-driven content
              Expanded(child: _buildBody()),

              // Bottom action
              if (_state == _BleState.idle) ...[
                PrimaryButton(label: 'Scan for devices', onTap: _startScan, icon: Icons.bluetooth_searching_rounded),
              ] else if (_state == _BleState.scanning) ...[
                const PrimaryButton(label: 'Scanning…', onTap: null, loading: true),
              ] else if (_state == _BleState.connected) ...[
                PrimaryButton(
                  label: 'Go to exercise list →',
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const ExerciseListScreen()),
                    );
                  },
                  color: AppColors.green,
                ),
                const SizedBox(height: 10),
              ] else if (_state == _BleState.found) ...[
                SecondaryButton(label: 'Scan again', onTap: _startScan),
              ],
              if (_state != _BleState.connected) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Skip for now', style: TextStyle(color: AppColors.slate400, fontSize: 14)),
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case _BleState.idle: return _buildIdle();
      case _BleState.scanning: return _buildScanning();
      case _BleState.found: return _buildDeviceList();
      case _BleState.connecting: return _buildConnecting();
      case _BleState.connected: return _buildConnected();
    }
  }

  Widget _buildIdle() {
    return ListView(children: const [
      SizedBox(height: 8),
      _StepTile(num: '1', title: 'Power on your armband', sub: 'Hold the side button for 3 seconds until the LED blinks teal'),
      _StepTile(num: '2', title: 'Enable Bluetooth on your phone', sub: 'Go to Settings → Bluetooth and ensure it is turned on'),
      _StepTile(num: '3', title: 'Wear the band on your affected arm', sub: 'Place sensors on the upper arm as instructed by your physiotherapist'),
    ]);
  }

  Widget _buildScanning() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        AnimatedBuilder(
          animation: _scanPulse,
          builder: (context, child) => Text(
            'Searching for InteliRehab devices…',
            style: TextStyle(fontSize: 14, color: AppColors.teal.withValues(alpha: 0.6 + 0.4 * _scanPulse.value), fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 10),
        const Text('Make sure Bluetooth is enabled', style: TextStyle(fontSize: 12, color: AppColors.slate400)),
      ]),
    );
  }

  Widget _buildDeviceList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${_devices.length} devices found', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.slate600)),
        const SizedBox(height: 10),
        ..._devices.asMap().entries.map((e) => GestureDetector(
          onTap: () => _connect(e.key),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.slate200, width: 1.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(10)),
                child: Icon(e.value.icon, color: AppColors.teal, size: 20)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.value.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.slate800)),
                Text(e.value.signal, style: const TextStyle(fontSize: 12, color: AppColors.slate400)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(8)),
                child: const Text('Connect', style: TextStyle(fontSize: 12, color: AppColors.white, fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
        )),
      ],
    );
  }

  Widget _buildConnecting() {
    final dev = _connecting != null ? _devices[_connecting!] : null;
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        AnimatedBuilder(
          animation: _connPulse,
          builder: (context, child) => Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.1 + 0.1 * _connPulse.value),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bluetooth_connected_rounded, color: AppColors.teal, size: 30),
          ),
        ),
        const SizedBox(height: 16),
        Text('Connecting to ${dev?.name ?? 'device'}…', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.slate800)),
        const SizedBox(height: 6),
        const Text('Establishing secure BLE connection', style: TextStyle(fontSize: 12, color: AppColors.slate400)),
      ]),
    );
  }

  Widget _buildConnected() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 32),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Wearable connected!', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.green)),
              const SizedBox(height: 4),
              Text(_devices[_connecting!].name, style: const TextStyle(fontSize: 13, color: AppColors.green)),
            ])),
          ]),
        ),
        const SizedBox(height: 18),
        const _ConnectedStat(label: 'Battery', value: '87%', icon: Icons.battery_charging_full_rounded, color: AppColors.green),
        const SizedBox(height: 10),
        const _ConnectedStat(label: 'IMU Signal', value: 'Strong', icon: Icons.sensors_rounded, color: AppColors.teal),
        const SizedBox(height: 10),
        const _ConnectedStat(label: 'EMG Channels', value: '2 active', icon: Icons.electric_bolt_rounded, color: AppColors.amber),
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  final String num, title, sub;
  const _StepTile({required this.num, required this.title, required this.sub});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 28, height: 28, alignment: Alignment.center,
          decoration: const BoxDecoration(color: AppColors.tealLight, shape: BoxShape.circle),
          child: Text(num, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.teal)),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.slate800)),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(fontSize: 12, color: AppColors.slate400, height: 1.4)),
        ])),
      ]),
    );
  }
}

class _ConnectedStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _ConnectedStat({required this.label, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(border: Border.all(color: AppColors.slate200), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.slate600)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }
}

class _BleVisual extends StatelessWidget {
  final _BleState state;
  final Animation<double> pulseCtrl;
  const _BleVisual({required this.state, required this.pulseCtrl});

  @override
  Widget build(BuildContext context) {
    if (state == _BleState.connecting || state == _BleState.connected) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: pulseCtrl,
      builder: (context, child) => Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          color: AppColors.tealLight,
          shape: BoxShape.circle,
          boxShadow: state == _BleState.scanning ? [BoxShadow(color: AppColors.teal.withValues(alpha: 0.2 * pulseCtrl.value), blurRadius: 30 * pulseCtrl.value, spreadRadius: 10 * pulseCtrl.value)] : [],
        ),
        child: const Icon(Icons.bluetooth_rounded, color: AppColors.teal, size: 32),
      ),
    );
  }
}