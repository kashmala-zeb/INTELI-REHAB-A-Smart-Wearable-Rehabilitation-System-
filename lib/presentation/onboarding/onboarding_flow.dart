import 'package:flutter/material.dart';
import 'package:inteli_rehab/core/constants/app_colors.dart';
import 'package:inteli_rehab/core/globals.dart';
import 'package:inteli_rehab/widgets/shared_widgets.dart';

// ── DATA MODELS ───────────────────────────────────────────────────────────────
class Clinic {
  final String name, address, city;
  final int patients;
  final IconData icon;
  Clinic({required this.name, required this.address, required this.city, required this.patients, required this.icon});
}

class Physiotherapist {
  final String name, specialty, clinic;
  final double rating;
  final int reviews, patients;
  final String availability;
  final Color color;
  Physiotherapist({required this.name, required this.specialty, required this.clinic, required this.rating, required this.reviews, required this.patients, required this.availability, required this.color});
}

class Injury {
  final String name, description, category;
  final IconData icon;
  Injury({required this.name, required this.description, required this.category, required this.icon});
}

// ── DUMMY DATA ─────────────────────────────────────────────────────────────────
final kClinics = [
  Clinic(name: 'HealthCare Physio & Rehab', address: 'Block 5, Clifton', city: 'Karachi', patients: 124, icon: Icons.local_hospital_rounded),
  Clinic(name: 'CareFirst Rehabilitation Center', address: 'F-7, Jinnah Ave', city: 'Islamabad', patients: 89, icon: Icons.medical_services_rounded),
  Clinic(name: 'Rehab Plus Sports Medicine', address: 'DHA Phase 2', city: 'Lahore', patients: 203, icon: Icons.healing_rounded),
  Clinic(name: 'ActiveLife Physiotherapy', address: 'Gulshan-e-Iqbal', city: 'Karachi', patients: 67, icon: Icons.self_improvement_rounded),
  Clinic(name: 'PIMS Allied Health Clinic', address: 'G-8/3, Sector G', city: 'Islamabad', patients: 310, icon: Icons.account_balance_rounded),
];

final kPhysiotherapists = [
  Physiotherapist(name: 'Dr. Ahmed Khan', specialty: 'Upper Limb & Sports Rehab', clinic: 'HealthCare Physio & Rehab', rating: 4.9, reviews: 148, patients: 62, availability: 'Mon–Fri, 9am–5pm', color: AppColors.teal),
  Physiotherapist(name: 'Dr. Sara Mirza', specialty: 'Post-Surgical Rehabilitation', clinic: 'HealthCare Physio & Rehab', rating: 4.7, reviews: 92, patients: 41, availability: 'Mon–Thu, 10am–4pm', color: const Color(0xFF8B5CF6)),
  Physiotherapist(name: 'Dr. Imran Baig', specialty: 'Musculoskeletal & Spine', clinic: 'HealthCare Physio & Rehab', rating: 4.5, reviews: 73, patients: 38, availability: 'Tue–Sat, 2pm–7pm', color: const Color(0xFFF59E0B)),
  Physiotherapist(name: 'Dr. Nadia Shah', specialty: 'Neurological Rehab & Balance', clinic: 'HealthCare Physio & Rehab', rating: 4.8, reviews: 114, patients: 55, availability: 'Mon, Wed, Fri 9am–3pm', color: AppColors.green),
];

final kInjuries = [
  Injury(name: 'Elbow Fracture / Post-Surgery', description: 'Fracture recovery, surgical fixation rehab', category: 'Elbow', icon: Icons.back_hand_rounded),
  Injury(name: 'Rotator Cuff Tear / Strain', description: 'Shoulder tendon injury, impingement', category: 'Shoulder', icon: Icons.sports_handball_rounded),
  Injury(name: 'Bicep / Tricep Tendon Repair', description: 'Tendon rupture or repair rehabilitation', category: 'Upper Arm', icon: Icons.fitness_center_rounded),
  Injury(name: 'Shoulder Dislocation', description: 'Joint dislocation, instability recovery', category: 'Shoulder', icon: Icons.account_balance_wallet_rounded),
  Injury(name: 'Forearm Ligament Injury', description: 'Sprain, ligament tear, TFCC injury', category: 'Forearm', icon: Icons.pan_tool_alt_rounded),
  Injury(name: 'Wrist Fracture / Sprain', description: 'Distal radius fracture, wrist sprain', category: 'Wrist', icon: Icons.front_hand_rounded),
  Injury(name: 'Shoulder Impingement', description: 'Subacromial impingement syndrome', category: 'Shoulder', icon: Icons.compress_rounded),
  Injury(name: 'Other Upper Limb Injury', description: 'Specify details in your profile', category: 'Other', icon: Icons.more_horiz_rounded),
];

const _stepLabels = ['Clinic', 'Physio', 'Injury', 'Details', 'Wearable'];

// ════════════════════════════════════════════════════════════════════════════════
// STEP 1 — CLINIC SELECTION
// ════════════════════════════════════════════════════════════════════════════════
class ClinicSelectionScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;
  const ClinicSelectionScreen({super.key, required this.onNext, this.onBack});

  @override
  State<ClinicSelectionScreen> createState() => _ClinicSelectionScreenState();
}

class _ClinicSelectionScreenState extends State<ClinicSelectionScreen> {
  int? _selected;
  final _searchCtrl = TextEditingController();
  String _search = '';

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final filtered = kClinics.where((c) => c.name.toLowerCase().contains(_search.toLowerCase()) || c.city.toLowerCase().contains(_search.toLowerCase())).toList();

    return OnboardingScaffold(
      step: 1, totalSteps: 5, stepLabels: _stepLabels, onBack: widget.onBack,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose your clinic', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.slate800)),
            const SizedBox(height: 6),
            const Text('Select the clinic where your physiotherapist practices', style: TextStyle(fontSize: 13, color: AppColors.slate400)),
            const SizedBox(height: 18),

            // Search bar
            TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(fontSize: 14, color: AppColors.slate800),
              decoration: InputDecoration(
                hintText: 'Search by clinic name or city…',
                hintStyle: const TextStyle(color: AppColors.slate400, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.slate400, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true, fillColor: AppColors.slate50,
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.slate200)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.teal, width: 1.5)),
              ),
            ),
            const SizedBox(height: 14),

            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final c = filtered[i];
                  final idx = kClinics.indexOf(c);
                  return SelectionCard(
                    title: c.name, subtitle: '${c.address}, ${c.city} · ${c.patients} patients',
                    icon: c.icon, selected: _selected == idx,
                    onTap: () => setState(() => _selected = idx),
                    trailing: _selected == idx
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.teal, size: 22)
                        : Text('${c.patients}', style: const TextStyle(fontSize: 11, color: AppColors.slate400)),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Continue',
              onTap: _selected != null ? widget.onNext : null,
              icon: Icons.arrow_forward_rounded,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// STEP 2 — PHYSIOTHERAPIST SELECTION
// ════════════════════════════════════════════════════════════════════════════════
class PhysiotherapistSelectionScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const PhysiotherapistSelectionScreen({super.key, required this.onNext, required this.onBack});

  @override
  State<PhysiotherapistSelectionScreen> createState() => _PhysioSelectionState();
}

class _PhysioSelectionState extends State<PhysiotherapistSelectionScreen> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 2, totalSteps: 5, stepLabels: _stepLabels, onBack: widget.onBack,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select your physiotherapist', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.slate800)),
            const SizedBox(height: 6),
            const Text('These therapists are registered at your selected clinic', style: TextStyle(fontSize: 13, color: AppColors.slate400)),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.builder(
                itemCount: kPhysiotherapists.length,
                itemBuilder: (_, i) => _PhysioCard(
                  physio: kPhysiotherapists[i],
                  selected: _selected == i,
                  onTap: () => setState(() => _selected = i),
                ),
              ),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Confirm therapist',
              onTap: _selected != null ? widget.onNext : null,
              icon: Icons.arrow_forward_rounded,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _PhysioCard extends StatelessWidget {
  final Physiotherapist physio;
  final bool selected;
  final VoidCallback onTap;
  const _PhysioCard({required this.physio, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.tealLight : AppColors.white,
          border: Border.all(color: selected ? AppColors.teal : AppColors.slate200, width: selected ? 1.8 : 1.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: physio.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: physio.color.withValues(alpha: 0.3), width: 2),
              ),
              child: Center(
                child: Text(
                  physio.name.split(' ').where((w) => w.isNotEmpty && w != 'Dr.').take(2).map((w) => w[0]).join(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: physio.color),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(physio.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.slate800))),
                      if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.teal, size: 20),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(physio.specialty, style: const TextStyle(fontSize: 12, color: AppColors.teal, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  // Rating row
                  Row(
                    children: [
                      StarRating(rating: physio.rating, size: 15),
                      const SizedBox(width: 6),
                      Text('${physio.rating}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.slate800)),
                      const SizedBox(width: 4),
                      Text('(${physio.reviews} reviews)', style: const TextStyle(fontSize: 11, color: AppColors.slate400)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 6,
                    children: [
                      _Chip(icon: Icons.people_rounded, label: '${physio.patients} patients'),
                      _Chip(icon: Icons.schedule_rounded, label: physio.availability),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppColors.slate100, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: AppColors.slate500),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.slate500, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// STEP 3 — INJURY SELECTION
// ════════════════════════════════════════════════════════════════════════════════
class InjurySelectionScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const InjurySelectionScreen({super.key, required this.onNext, required this.onBack});

  @override
  State<InjurySelectionScreen> createState() => _InjurySelectionState();
}

class _InjurySelectionState extends State<InjurySelectionScreen> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    // Group by category
    final categories = kInjuries.map((i) => i.category).toSet().toList();

    return OnboardingScaffold(
      step: 3, totalSteps: 5, stepLabels: _stepLabels, onBack: widget.onBack,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('What is your injury?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.slate800)),
            const SizedBox(height: 6),
            const Text('Select the injury or condition you are recovering from', style: TextStyle(fontSize: 13, color: AppColors.slate400)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: categories.map((cat) {
                  final items = kInjuries.where((i) => i.category == cat).toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(cat.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.slate400, letterSpacing: 1.2)),
                      ),
                      ...items.map((inj) {
                        final idx = kInjuries.indexOf(inj);
                        return SelectionCard(
                          title: inj.name, subtitle: inj.description,
                          icon: inj.icon, selected: _selected == idx,
                          onTap: () => setState(() => _selected = idx),
                        );
                      }),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            PrimaryButton(label: 'Continue', onTap: _selected != null ? widget.onNext : null, icon: Icons.arrow_forward_rounded),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// STEP 4 — BASIC DETAILS
// ════════════════════════════════════════════════════════════════════════════════
class BasicDetailsScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const BasicDetailsScreen({super.key, required this.onNext, required this.onBack});

  @override
  State<BasicDetailsScreen> createState() => _BasicDetailsState();
}

class _BasicDetailsState extends State<BasicDetailsScreen> {
  final _nameCtrl    = TextEditingController();
  final _ageCtrl     = TextEditingController();
  final _weightCtrl  = TextEditingController();
  final _heightCtrl  = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _notesCtrl   = TextEditingController();
  String _gender = 'Female';
  String _dominantArm = 'Right';
  String _affectedArm = 'Right';

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(() => setState(() {}));
    _ageCtrl.addListener(() => setState(() {}));
    _weightCtrl.addListener(() => setState(() {}));
    _heightCtrl.addListener(() => setState(() {}));
    _phoneCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _ageCtrl.dispose(); _weightCtrl.dispose();
    _heightCtrl.dispose(); _phoneCtrl.dispose(); _notesCtrl.dispose();
    super.dispose();
  }

  bool get _isValid {
    if (_nameCtrl.text.trim().isEmpty) return false;
    if (_phoneCtrl.text.trim().isEmpty || _phoneError != null) return false;
    if (_ageCtrl.text.trim().isEmpty || _ageError != null) return false;
    if (_weightCtrl.text.trim().isEmpty || _weightError != null) return false;
    if (_heightCtrl.text.trim().isEmpty || _heightError != null) return false;
    return true;
  }

  String? get _phoneError {
    final text = _phoneCtrl.text.trim();
    if (text.isEmpty) return null;
    if (!RegExp(r'^\d{10,15}$').hasMatch(text)) return 'Enter a valid phone number.';
    return null;
  }

  String? get _ageError {
    final text = _ageCtrl.text.trim();
    if (text.isEmpty) return null;
    if (!RegExp(r'^[1-9]\d*$').hasMatch(text)) return 'Age must be between 12 and 120 years.';
    final age = int.tryParse(text);
    if (age == null || age < 12 || age > 120) return 'Age must be between 12 and 120 years.';
    return null;
  }

  String? get _weightError {
    final text = _weightCtrl.text.trim();
    if (text.isEmpty) return null;
    if (!RegExp(r'^\d+(\.\d)?$').hasMatch(text)) return 'Weight must be between 20 and 200 kg.';
    final weight = double.tryParse(text);
    if (weight == null || weight < 20 || weight > 200) return 'Weight must be between 20 and 200 kg.';
    return null;
  }

  String? get _heightError {
    final text = _heightCtrl.text.trim();
    if (text.isEmpty) return null;
    if (!RegExp(r'^\d+(\.\d)?$').hasMatch(text)) return 'Height must be between 30 and 200 cm.';
    final height = double.tryParse(text);
    if (height == null || height < 30 || height > 200) return 'Height must be between 30 and 200 cm.';
    return null;
  }

  Widget _segmented(String label, List<String> opts, String val, ValueChanged<String> onChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.slate500, letterSpacing: 0.6)),
        const SizedBox(height: 8),
        Container(
          height: 44,
          decoration: BoxDecoration(color: AppColors.slate100, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: opts.map((o) => Expanded(
              child: GestureDetector(
                onTap: () => setState(() => onChange(o)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: val == o ? AppColors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: val == o ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 1))] : [],
                  ),
                  child: Center(
                    child: Text(o, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: val == o ? AppColors.teal : AppColors.slate500)),
                  ),
                ),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 4, totalSteps: 5, stepLabels: _stepLabels, onBack: widget.onBack,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.slate800)),
            const SizedBox(height: 6),
            const Text('This helps personalise your rehabilitation programme', style: TextStyle(fontSize: 13, color: AppColors.slate400)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  AppTextField(label: 'Full name', hint: 'Ayesha Malik', controller: _nameCtrl),
                  const SizedBox(height: 16),
                  AppTextField(label: 'Phone number', hint: '+92 300 0000000', controller: _phoneCtrl, keyboardType: TextInputType.phone, errorText: _phoneError),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: AppTextField(label: 'Age', hint: '28', controller: _ageCtrl, keyboardType: TextInputType.number, errorText: _ageError)),
                    const SizedBox(width: 12),
                    Expanded(child: AppTextField(label: 'Weight (kg)', hint: '65', controller: _weightCtrl, keyboardType: TextInputType.number, errorText: _weightError)),
                    const SizedBox(width: 12),
                    Expanded(child: AppTextField(label: 'Height (cm)', hint: '170', controller: _heightCtrl, keyboardType: TextInputType.number, errorText: _heightError)),
                  ]),
                  const SizedBox(height: 18),
                  _segmented('Gender', ['Female', 'Male', 'Other'], _gender, (v) => _gender = v),
                  const SizedBox(height: 18),
                  _segmented('Dominant arm', ['Right', 'Left'], _dominantArm, (v) => _dominantArm = v),
                  const SizedBox(height: 18),
                  _segmented('Affected arm', ['Right', 'Left', 'Both'], _affectedArm, (v) => _affectedArm = v),
                  const SizedBox(height: 18),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ADDITIONAL NOTES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.slate500, letterSpacing: 0.6)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _notesCtrl,
                        maxLines: 3,
                        style: const TextStyle(fontSize: 14, color: AppColors.slate800),
                        decoration: InputDecoration(
                          hintText: 'e.g. Surgery date, allergies, relevant medical history…',
                          hintStyle: const TextStyle(color: AppColors.slate400, fontSize: 13),
                          contentPadding: const EdgeInsets.all(14),
                          filled: true, fillColor: AppColors.white,
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.slate200, width: 1.5)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.teal, width: 1.8)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            PrimaryButton(
              label: 'Continue',
              onTap: _isValid ? widget.onNext : null,
              icon: Icons.arrow_forward_rounded,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// STEP 5 — WEARABLE BLUETOOTH CONNECTION
// ════════════════════════════════════════════════════════════════════════════════
class WearableConnectionScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const WearableConnectionScreen({super.key, required this.onNext, required this.onBack});

  @override
  State<WearableConnectionScreen> createState() => _WearableConnectionState();
}

class _WearableConnectionState extends State<WearableConnectionScreen> with TickerProviderStateMixin {
  _BleState _state = _BleState.idle;
  int? _connecting; // index of device being connected

  late final AnimationController _scanPulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
  late final AnimationController _connPulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);

  final _devices = [
    const _BleDevice('InteliRehab Band X1', 'Signal: Strong', Icons.watch_rounded, AppColors.teal),
    const _BleDevice('InteliRehab Band X1', 'Signal: Moderate', Icons.watch_rounded, AppColors.amber),
    const _BleDevice('InteliRehab Sensor v2', 'Signal: Strong', Icons.sensors_rounded, AppColors.teal),
  ];

  @override
  void dispose() { _scanPulse.dispose(); _connPulse.dispose(); super.dispose(); }

  void _startScan() async {
    setState(() => _state = _BleState.scanning);
    await Future.delayed(const Duration(milliseconds: 2200));
    if (mounted) setState(() => _state = _BleState.found);
  }

  void _connect(int idx) async {
    setState(() { _state = _BleState.connecting; _connecting = idx; });
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) setState(() => _state = _BleState.connected);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 5, totalSteps: 5, stepLabels: _stepLabels, onBack: widget.onBack,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
              PrimaryButton(label: 'Go to my dashboard →', onTap: widget.onNext, color: AppColors.green),
              const SizedBox(height: 10),
            ] else if (_state == _BleState.found) ...[
              SecondaryButton(label: 'Scan again', onTap: _startScan),
            ],
            if (_state != _BleState.connected)
              TextButton(
                onPressed: widget.onNext,
                child: const Text('Skip for now', style: TextStyle(color: AppColors.slate400, fontSize: 14)),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case _BleState.idle:
        return _buildIdle();
      case _BleState.scanning:
        return _buildScanning();
      case _BleState.found:
        return _buildDeviceList();
      case _BleState.connecting:
        return _buildConnecting();
      case _BleState.connected:
        return _buildConnected();
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

enum _BleState { idle, scanning, found, connecting, connected }

class _BleDevice {
  final String name, signal;
  final IconData icon;
  final Color color;
  const _BleDevice(this.name, this.signal, this.icon, this.color);
}

class _BleVisual extends StatelessWidget {
  final _BleState state;
  final AnimationController pulseCtrl;
  const _BleVisual({required this.state, required this.pulseCtrl});

  @override
  Widget build(BuildContext context) {
    final isConnected = state == _BleState.connected;
    final isActive = state == _BleState.scanning || state == _BleState.connecting;

    return AnimatedBuilder(
      animation: pulseCtrl,
      builder: (_, child) {
        final pulse = isActive ? (0.95 + 0.05 * pulseCtrl.value) : 1.0;
        return Transform.scale(
          scale: pulse,
          child: Stack(alignment: Alignment.center, children: [
            if (isActive) Container(
              width: 120, height: 120,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.teal.withValues(alpha: 0.07 + 0.05 * pulseCtrl.value)),
            ),
            Container(
              width: 88, height: 88,
              decoration: BoxDecoration(
                color: isConnected ? AppColors.greenLight : AppColors.tealLight,
                shape: BoxShape.circle,
                border: Border.all(color: isConnected ? AppColors.green : AppColors.teal, width: 2),
              ),
              child: Icon(
                isConnected ? Icons.bluetooth_connected_rounded : Icons.bluetooth_rounded,
                color: isConnected ? AppColors.green : AppColors.teal,
                size: 40,
              ),
            ),
          ]),
        );
      },
    );
  }
}

class _StepTile extends StatelessWidget {
  final String num, title, sub;
  const _StepTile({required this.num, required this.title, required this.sub});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 28, height: 28,
          decoration: const BoxDecoration(color: AppColors.tealLight, shape: BoxShape.circle),
          child: Center(child: Text(num, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.tealDim))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.slate800)),
          const SizedBox(height: 3),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppColors.white, border: Border.all(color: AppColors.slate200), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.slate600)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// ONBOARDING MANAGER
// ════════════════════════════════════════════════════════════════════════════════
class OnboardingManagerScreen extends StatefulWidget {
  const OnboardingManagerScreen({super.key});

  @override
  State<OnboardingManagerScreen> createState() => _OnboardingManagerScreenState();
}

class _OnboardingManagerScreenState extends State<OnboardingManagerScreen> {
  final PageController _pageController = PageController();

  void _nextStep() {
    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _prevStep() {
    _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _finishOnboarding() {
    globalIsDeviceConnected = true;
    // Navigate
    Navigator.of(context).pushReplacementNamed('/wait_screen');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Prevent manual swipe
        children: [
          ClinicSelectionScreen(
            onNext: _nextStep,
            onBack: () => Navigator.of(context).pop(), // Goes back to create account
          ),
          PhysiotherapistSelectionScreen(
            onNext: _nextStep,
            onBack: _prevStep,
          ),
          InjurySelectionScreen(
            onNext: _nextStep,
            onBack: _prevStep,
          ),
          BasicDetailsScreen(
            onNext: _nextStep,
            onBack: _prevStep,
          ),
          WearableConnectionScreen(
            onNext: _finishOnboarding,
            onBack: _prevStep,
          ),
        ],
      ),
    );
  }
}
