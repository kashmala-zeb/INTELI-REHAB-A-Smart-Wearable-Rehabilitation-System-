import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:inteli_rehab/presentation/home/home_dashboard.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Color Tokens (Consistent with INTELI-REHAB)
// ─────────────────────────────────────────────────────────────────────────────
const _primary   = Color(0xFF0F766E); // Teal core
const _secondary = Color(0xFF14B8A6); // Bright cyan
const _bg        = Color(0xFFF0FAFA); // Light teal background
const _card      = Colors.white;
const _success   = Color(0xFF10B981);
const _warning   = Color(0xFFF59E0B);
const _danger    = Color(0xFFEF4444);
const _accentPurple = Color(0xFF8B5CF6);
const _accentCyan   = Color(0xFF06B6D4);

// ─────────────────────────────────────────────────────────────────────────────
// Summary Screen
// ─────────────────────────────────────────────────────────────────────────────
class ExerciseSummaryScreen extends StatefulWidget {
  final String exerciseName;
  final int repsCompleted;
  final int targetReps;
  final double accuracy;
  final int maxRom;
  final String durationText;

  const ExerciseSummaryScreen({
    super.key,
    this.exerciseName = 'Elbow Flexion Training',
    this.repsCompleted = 60,
    this.targetReps = 60,
    this.accuracy = 95,
    this.maxRom = 145,
    this.durationText = '26 min',
  });

  @override
  State<ExerciseSummaryScreen> createState() => _ExerciseSummaryScreenState();
}

class _ExerciseSummaryScreenState extends State<ExerciseSummaryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Staggered Animations
  late final Animation<double> _scoreRingAnim;
  late final Animation<double> _todayRomRingAnim;
  late final Animation<double> _graphProgressAnim;
  late final Animation<double> _cardsFadeAnim;

  bool _checkAnim = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800));

    // Eased animations
    final CurvedAnimation easeOutCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 0.9, curve: Curves.easeOutBack));

    _scoreRingAnim = Tween<double>(begin: 0, end: 95).animate(easeOutCurve);
    _todayRomRingAnim = Tween<double>(begin: 0, end: 145).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.8, curve: Curves.easeOut)));

    _graphProgressAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0, curve: Curves.easeInOut)));

    _cardsFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7, curve: Curves.easeOut)));

    _controller.forward();

    // Trigger checkmark pop animation
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _checkAnim = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        top: false, // Make gradient flow into the status bar area beautifully
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────────────────
              _buildHeader(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: FadeTransition(
                  opacity: _cardsFadeAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Overall Performance Card ───────────────────────────────
                      _buildOverallPerformanceCard(),
                      const SizedBox(height: 16),

                      // ── Session Statistics Grid ────────────────────────────────
                      const Text(
                        'SESSION STATISTICS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: Color(0xFF5E8A85))),
                      const SizedBox(height: 8),
                      _buildStatsGrid(),
                      const SizedBox(height: 16),

                      // ── Recovery Progress Line Chart ───────────────────────────
                      _buildRecoveryProgressCard(),
                      const SizedBox(height: 16),

                      // ── ROM + Muscle Activity Row ──────────────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildROMCard()),
                          const SizedBox(width: 12),
                          Expanded(child: _buildMuscleActivityCard()),
                        ]),
                      const SizedBox(height: 16),

                      // ── AI Assessment Card ─────────────────────────────────────
                      _buildAIAssessmentCard(),
                      const SizedBox(height: 16),

                      // ── Therapist Review Card ──────────────────────────────────
                      _buildTherapistReviewCard(),
                      const SizedBox(height: 16),

                      // ── Session Timeline Card ──────────────────────────────────
                      _buildSessionTimelineCard(),
                      const SizedBox(height: 16),

                      // ── Today's Recommendation Card ────────────────────────────
                      _buildRecommendationCard(),
                      const SizedBox(height: 20),

                      // ── Bottom Action Buttons ──────────────────────────────────
                      _buildBottomActions(context),
                      const SizedBox(height: 24),
                    ]))),
            ]))));
  }

  // ── Header Component ───────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary, Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'STEP 5 OF 5',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Color(0xFFCCFBF1))),
              Row(
                children: List.generate(5, (index) {
                  return Container(
                    margin: const EdgeInsets.only(left: 4),
                    width: 24,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4)));
                })),
            ]),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkmark Circle Animation
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.25 * 255).round()),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withAlpha((0.60 * 255).round()), width: 2)),
                child: Center(
                  child: AnimatedScale(
                    scale: _checkAnim ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutBack,
                    child: const Icon(Icons.done_all_rounded, color: Colors.white, size: 28)))),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rehabilitation Session Complete',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_month_outlined, color: const Color(0xFFCCFBF1).withAlpha((0.9 * 255).round()), size: 12),
                        const SizedBox(width: 4),
                        const Text(
                          '12 July 2026',
                          style: TextStyle(fontSize: 11, color: Color(0xFFCCFBF1))),
                        const SizedBox(width: 8),
                        Text('·', style: TextStyle(color: Colors.white.withAlpha((0.40 * 255).round()))),
                        const SizedBox(width: 8),
                        Icon(Icons.fitness_center_rounded, color: const Color(0xFFCCFBF1).withAlpha((0.9 * 255).round()), size: 12),
                        const SizedBox(width: 4),
                        const Text(
                          'Elbow Flexion Training',
                          style: TextStyle(fontSize: 11, color: Color(0xFFCCFBF1))),
                      ]),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((0.20 * 255).round()),
                        borderRadius: BorderRadius.circular(20)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Completed Successfully',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                        ])),
                  ])),
            ]),
        ]));
  }

  // ── Overall Performance Card ───────────────────────────────────────────────
  Widget _buildOverallPerformanceCard() {
    return GestureDetector(
      onTap: () => _showPerformanceSheet(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: _primary.withAlpha((0.08 * 255).round()), blurRadius: 20, offset: const Offset(0, 4))]),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: AnimatedBuilder(
                    animation: _scoreRingAnim,
                    builder: (context, _) => CircularProgressIndicator(
                      value: _scoreRingAnim.value / 100,
                      strokeWidth: 7,
                      backgroundColor: const Color(0xFFCCFBF1),
                      valueColor: const AlwaysStoppedAnimation(_primary),
                      strokeCap: StrokeCap.round))),
                Text(
                  '${widget.accuracy}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _primary)),
              ]),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OVERALL PERFORMANCE',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF5E8A85), letterSpacing: 1.0)),
                  SizedBox(height: 2),
                  Text(
                    'Excellent Recovery Session',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0D2B2B))),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.trending_up_rounded, color: _primary, size: 14),
                      SizedBox(width: 2),
                      Text(
                        '+6% from last session',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _primary)),
                    ]),
                ])),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFCCFBF1), size: 20),
          ])));
  }

  // ── Session Statistics Grid ────────────────────────────────────────────────
  Widget _buildStatsGrid() {
    final statsData = [
      _StatItem(Icons.gps_fixed_rounded, 'Accuracy', '95%', '+3% vs last', _primary, 'Accuracy reflects how closely your movements matched the prescribed exercise pattern. 95% is in the excellent range — above the clinical threshold of 80%.'),
      _StatItem(Icons.replay_rounded, 'Max ROM', '145°', '+7° vs last', _accentCyan, 'Maximum Range of Motion achieved during the session. Your target was 140°, which you exceeded by 5°, indicating excellent joint mobility progress.'),
      _StatItem(Icons.analytics_rounded, 'Avg ROM', '138°', '+5° vs last', _accentPurple, 'Average Range of Motion maintained throughout all repetitions. A high average close to the max indicates consistent, controlled movement quality.'),
      _StatItem(Icons.timer_outlined, 'Exercise Time', '26 min', 'On target', _warning, 'Total active exercise time, excluding rest periods and calibration. 26 minutes aligns with your prescribed protocol of 25–30 minutes.'),
      _StatItem(Icons.repeat_rounded, 'Repetitions', '60/60', '100% complete', _success, 'You completed all 60 prescribed repetitions without stopping. Full completion correlates strongly with recovery outcomes.'),
      _StatItem(Icons.bolt_rounded, 'Muscle Activation', '41%', '+4% vs last', _danger, 'Average muscle activation level measured via surface EMG sensors. 41% is within the therapeutic range for early-phase rehabilitation, preventing overexertion.'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        mainAxisExtent: 104),
      itemCount: 6,
      itemBuilder: (context, index) {
        final item = statsData[index];
        return GestureDetector(
          onTap: () => _showStatSheet(item),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: _primary.withAlpha((0.04 * 255).round()), blurRadius: 10)]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: item.color.withAlpha((0.10 * 255).round()),
                    borderRadius: BorderRadius.circular(10)),
                  child: Icon(item.icon, size: 16, color: item.color)),
                const Spacer(),
                Text(
                  item.label,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF5E8A85)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
                const SizedBox(height: 1),
                Text(
                  item.value,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0D2B2B))),
              ])));
      });
  }

  // ── Recovery Progress Graph Card ───────────────────────────────────────────
  Widget _buildRecoveryProgressCard() {
    return GestureDetector(
      onTap: () => _showRecoverySheet(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: _primary.withAlpha((0.08 * 255).round()), blurRadius: 20, offset: const Offset(0, 4))]),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('RECOVERY PROGRESS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF5E8A85), letterSpacing: 1.0)),
                    SizedBox(height: 2),
                    Text('Movement Quality', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0D2B2B))),
                  ]),
                Row(
                  children: [
                    Icon(Icons.trending_up_rounded, color: _primary, size: 14),
                    SizedBox(width: 2),
                    Text('+33 pts', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _primary)),
                  ]),
              ]),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _graphProgressAnim,
              builder: (context, _) => SizedBox(
                height: 90,
                width: double.infinity,
                child: CustomPaint(
                  painter: _RecoveryCurvePainter(progress: _graphProgressAnim.value)))),
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('0%', style: TextStyle(fontSize: 9, color: Color(0xFF5E8A85))),
                  Text('20%', style: TextStyle(fontSize: 9, color: Color(0xFF5E8A85))),
                  Text('40%', style: TextStyle(fontSize: 9, color: Color(0xFF5E8A85))),
                  Text('60%', style: TextStyle(fontSize: 9, color: Color(0xFF5E8A85))),
                  Text('80%', style: TextStyle(fontSize: 9, color: Color(0xFF5E8A85))),
                  Text('100%', style: TextStyle(fontSize: 9, color: Color(0xFF5E8A85))),
                ])),
            const SizedBox(height: 10),
            const Text(
              'Tap to open full analytics view',
              style: TextStyle(fontSize: 10, color: Color(0xFF5E8A85))),
          ])));
  }

  // ── Range of Motion Card ───────────────────────────────────────────────────
  Widget _buildROMCard() {
    return GestureDetector(
      onTap: () => _showROMSheet(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: _primary.withAlpha((0.08 * 255).round()), blurRadius: 20)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('RANGE OF MOTION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF5E8A85), letterSpacing: 0.8)),
            const SizedBox(height: 12),
            Center(
              child: AnimatedBuilder(
                animation: _todayRomRingAnim,
                builder: (context, _) => SizedBox(
                  width: 100,
                  height: 60,
                  child: CustomPaint(
                    painter: _ROMGaugePainter(angle: _todayRomRingAnim.value))))),
            const SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  const Text('145°', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _primary)),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: _success, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      const Text('Target Achieved', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _success)),
                    ]),
                  const SizedBox(height: 4),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_upward_rounded, color: _primary, size: 10),
                      SizedBox(width: 2),
                      Text('+7° vs last', style: TextStyle(fontSize: 9, color: Color(0xFF5E8A85))),
                    ]),
                ])),
          ])));
  }

  // ── Muscle Activity Card ───────────────────────────────────────────────────
  Widget _buildMuscleActivityCard() {
    return GestureDetector(
      onTap: () => _showMuscleSheet(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: _primary.withAlpha((0.08 * 255).round()), blurRadius: 20)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('MUSCLE ACTIVITY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF5E8A85), letterSpacing: 0.8)),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Biceps', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0D2B2B))),
                Text('41%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _primary)),
              ]),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const LinearProgressIndicator(
                value: 0.41,
                minHeight: 5,
                backgroundColor: Color(0xFFCCFBF1),
                valueColor: AlwaysStoppedAnimation(_primary))),
            const SizedBox(height: 14),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Triceps', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0D2B2B))),
                Text('38%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _accentCyan)),
              ]),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const LinearProgressIndicator(
                value: 0.38,
                minHeight: 5,
                backgroundColor: Color(0xFFCCFBF1),
                valueColor: AlwaysStoppedAnimation(_accentCyan))),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Tap for EMG graphs',
                style: TextStyle(fontSize: 10, color: Color(0xFF5E8A85)))),
          ])));
  }

  // ── AI Assessment Card ─────────────────────────────────────────────────────
  Widget _buildAIAssessmentCard() {
    final assessments = [
      _AIAssessItem('Correct Joint Alignment', 'Your shoulder, elbow, and wrist maintained proper alignment throughout 94% of repetitions. Minor deviation noted in reps 12–14 — likely due to mild fatigue.'),
      _AIAssessItem('Stable Movement Speed', 'Movement velocity remained consistent between 45–60°/sec, well within the prescribed therapeutic window. No ballistic or jerky movements detected.'),
      _AIAssessItem('Proper Muscle Activation', 'Agonist-antagonist co-activation ratio was 1.08, indicating healthy neuromuscular coordination. No compensation patterns from secondary muscles detected.'),
      _AIAssessItem('Good Exercise Form', 'Postural assessment score: 92/100. Trunk remained stable and upright. No compensatory torso rotation or shoulder elevation detected.'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: _primary.withAlpha((0.08 * 255).round()), blurRadius: 20, offset: const Offset(0, 4))]),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(color: Color(0xFFE6F7F5), shape: BoxShape.circle),
                child: const Icon(Icons.psychology_rounded, size: 15, color: _primary)),
              const SizedBox(width: 8),
              const Text(
                'AI Assessment',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0D2B2B))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(12)),
                child: const Text('4/4 Passed', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _primary))),
            ]),
          const SizedBox(height: 12),
          ...assessments.map((item) => GestureDetector(
            onTap: () => _showAISheet(item),
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FAFA),
                borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(color: _success, shape: BoxShape.circle),
                    child: const Icon(Icons.done_rounded, color: Colors.white, size: 12)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.label,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0D2B2B)))),
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFFCCFBF1), size: 16),
                ])))),
        ]));
  }

  // ── Therapist Review Card ──────────────────────────────────────────────────
  Widget _buildTherapistReviewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primary, Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: _primary.withAlpha((0.25 * 255).round()), blurRadius: 20, offset: const Offset(0, 8))]),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: Colors.white.withAlpha((0.20 * 255).round()), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.cloud_outlined, color: Colors.white, size: 18)),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Therapist Review',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        BadgePulseDot(),
                        SizedBox(width: 4),
                        Text(
                          'Session data synchronized securely',
                          style: TextStyle(fontSize: 10, color: Color(0xFFCCFBF1))),
                      ]),
                  ])),
              Icon(Icons.wifi_rounded, color: Colors.white.withAlpha((0.60 * 255).round()), size: 16),
            ]),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => _showTherapistReportSheet(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _primary,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0),
            icon: const Icon(Icons.bar_chart_rounded, size: 16),
            label: const Text('View Detailed Report', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
        ]));
  }

  // ── Session Timeline Card ──────────────────────────────────────────────────
  Widget _buildSessionTimelineCard() {
    final timelineData = [
      _TimelineItem('Calibration Complete', '09:14', Icons.check_circle_outline_rounded, 'All sensors verified. IMU calibration, EMG baseline, and range of motion reference angles established. System ready for session capture.'),
      _TimelineItem('Session Started', '09:15', Icons.play_arrow_rounded, 'First repetition initiated. Movement tracking, EMG recording, and real-time feedback algorithms activated.'),
      _TimelineItem('Session Finished', '09:41', Icons.check_circle_rounded, 'All 60 repetitions completed successfully. Session data secured and sent for analysis.'),
      _TimelineItem('Results Saved', '09:41', Icons.save_rounded, 'Full session data — kinematics, EMG, ROM, quality scores — saved to secure cloud storage and synchronized with therapist portal.'),

    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: _primary.withAlpha((0.08 * 255).round()), blurRadius: 20, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SESSION TIMELINE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF5E8A85), letterSpacing: 1.0)),
          const SizedBox(height: 16),
          Stack(
            children: [
              // Horizontal connector line
              Positioned(
                top: 18,
                left: 20,
                right: 20,
                child: Container(
                  height: 2,
                  color: const Color(0xFFCCFBF1))),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: timelineData.map((item) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _showTimelineSheet(item),
                      child: Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Color(0xFFCCFBF1),
                              shape: BoxShape.circle),
                            child: Center(
                              child: Icon(item.icon, color: _primary, size: 16))),
                          const SizedBox(height: 6),
                          Text(
                            item.label,
                            style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w600, color: Color(0xFF0D2B2B)),
                            textAlign: TextAlign.center,
                            maxLines: 2),
                          const SizedBox(height: 2),
                          Text(
                            item.time,
                            style: const TextStyle(fontSize: 8.5, color: Color(0xFF5E8A85))),
                        ])));
                }).toList()),
            ]),
        ]));
  }

  // ── Today's Recommendation Card ────────────────────────────────────────────
  Widget _buildRecommendationCard() {
    return GestureDetector(
      onTap: () => _showRecommendationSheet(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE6F7F5)),
          boxShadow: [BoxShadow(color: _primary.withAlpha((0.08 * 255).round()), blurRadius: 20, offset: const Offset(0, 4))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(color: Color(0xFFFEF3C7), shape: BoxShape.circle),
                  child: const Icon(Icons.bolt_rounded, color: _warning, size: 16)),
                const SizedBox(width: 8),
                const Text(
                  "Today's Recommendation",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0D2B2B))),
              ]),
            const SizedBox(height: 12),
            const Text(
              '"Move slightly slower during the final repetitions to improve motor control and reduce fatigue-related errors."',
              style: TextStyle(fontSize: 13, color: Color(0xFF0D2B2B), fontStyle: FontStyle.italic, height: 1.4)),
            const SizedBox(height: 10),
            const Row(
              children: [
                Text('Learn More', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _primary)),
                SizedBox(width: 2),
                Icon(Icons.chevron_right_rounded, color: _primary, size: 14),
              ]),
          ])));
  }

  // ── Bottom Action Buttons ──────────────────────────────────────────────────
  Widget _buildBottomActions(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeDashboardScreen()),
              (route) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 4,
            shadowColor: _primary.withAlpha((0.35 * 255).round())),
          icon: const Icon(Icons.home_rounded, size: 16),
          label: const Text('Finish Session', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Preparing to share report...')));
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 44),
            side: const BorderSide(color: Color(0xFFCCFBF1), width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            foregroundColor: _primary,
            backgroundColor: Colors.white),
          icon: const Icon(Icons.share_rounded, size: 14),
          label: const Text('Share Report', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => _showRecoverySheet(),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF5E8A85)),
          icon: const Icon(Icons.bar_chart_rounded, size: 15),
          label: const Text('View Full Analytics', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
      ]);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Bottom Sheet Triggers & Renderers
  // ───────────────────────────────────────────────────────────────────────────
  void _showBottomSheet(String title, Widget content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottom sheet drag handle + header row
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(2)))),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0D2B2B))),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(color: Color(0xFFF0FAFA), shape: BoxShape.circle),
                      child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF5E8A85)))),
                ]),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFE6F7F5), height: 1),
              const SizedBox(height: 16),
              content,
            ]));
      });
  }

  void _showPerformanceSheet() {
    _showBottomSheet(
      'Performance Report',
      Column(
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: 0.95,
                    strokeWidth: 8,
                    backgroundColor: Color(0xFFCCFBF1),
                    valueColor: AlwaysStoppedAnimation(_primary),
                    strokeCap: StrokeCap.round)),
                Text(
                  '${widget.accuracy}%',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _primary)),
              ])),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFF0FAFA), borderRadius: BorderRadius.circular(16)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Clinical Assessment', style: TextStyle(fontSize: 10, color: Color(0xFF5E8A85), fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(
                  'Your overall performance score of 95% places this session in the top 10% of recorded rehabilitation sessions for elbow flexion training at this stage of recovery.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF0D2B2B), height: 1.4)),
              ])),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.1,
            children: [
              _buildMinicard('Accuracy', '95%'),
              _buildMinicard('ROM', '145°'),
              _buildMinicard('Adherence', '100%'),
              _buildMinicard('Quality', '92/100'),
            ]),
        ]));
  }

  Widget _buildMinicard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFFF0FAFA), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF5E8A85))),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _primary)),
        ]));
  }

  void _showStatSheet(_StatItem item) {
    _showBottomSheet(
      item.label,
      Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFF0FAFA), borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: item.color.withAlpha((0.15 * 255).round()), borderRadius: BorderRadius.circular(12)),
                  child: Icon(item.icon, color: item.color, size: 20)),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: item.color)),
                    Text(item.trendText, style: const TextStyle(fontSize: 11, color: Color(0xFF5E8A85))),
                  ]),
              ])),
          const SizedBox(height: 16),
          Text(
            item.detail,
            style: const TextStyle(fontSize: 13, color: Color(0xFF0D2B2B), height: 1.4)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFE6F7F5), borderRadius: BorderRadius.circular(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Comparison with previous sessions', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _primary)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(value: 0.78, minHeight: 6, backgroundColor: Color(0xFFCCFBF1), valueColor: AlwaysStoppedAnimation(_primary))),
                const SizedBox(height: 4),
                const Text('Better than 78% of your previous sessions', style: TextStyle(fontSize: 9.5, color: Color(0xFF5E8A85))),
              ])),
        ]));
  }

  void _showRecoverySheet() {
    _showBottomSheet(
      'Movement Quality Analytics',
      Column(
        children: [
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CustomPaint(
              painter: _RecoveryCurvePainter(progress: 1.0, isExpanded: true))),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Start', style: TextStyle(fontSize: 10, color: Color(0xFF5E8A85))),
                Text('Midpoint', style: TextStyle(fontSize: 10, color: Color(0xFF5E8A85))),
                Text('Finish', style: TextStyle(fontSize: 10, color: Color(0xFF5E8A85))),
              ])),
          const SizedBox(height: 16),
          const Text(
            'Movement quality improved consistently throughout the session, starting at 62 and reaching a peak of 95 at session end. This trajectory indicates effective neuromuscular adaptation and healthy movement patterns.',
            style: TextStyle(fontSize: 12.5, color: Color(0xFF0D2B2B), height: 1.4)),
        ]));
  }

  void _showROMSheet() {
    _showBottomSheet(
      'Range of Motion History',
      Column(
        children: [
          SizedBox(
            width: 150,
            height: 90,
            child: CustomPaint(
              painter: _ROMGaugePainter(angle: 145))),
          const SizedBox(height: 12),
          const Center(
            child: Column(
              children: [
                Text('145°', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _primary)),
                Text('Maximum achieved — Target: 140°', style: TextStyle(fontSize: 12, color: Color(0xFF5E8A85))),
              ])),
          const SizedBox(height: 16),
          ...[
            ['Session 1', '112°'],
            ['Session 2', '124°'],
            ['Session 3', '131°'],
            ['Session 4', '138°'],
            ['Today', '145°']
          ].map((s) => Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: const Color(0xFFF0FAFA), borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(s[0], style: const TextStyle(fontSize: 12, color: Color(0xFF5E8A85))),
                Text(s[1], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _primary)),
              ]))),
        ]));
  }

  void _showMuscleSheet() {
    final list = [
      _MuscleDetail('Biceps Brachii', 41, _primary),
      _MuscleDetail('Triceps Brachii', 38, _accentCyan),
      _MuscleDetail('Brachioradialis', 22, _accentPurple),
      _MuscleDetail('Deltoid (Ant.)', 18, _warning),
    ];

    _showBottomSheet(
      'EMG Muscle Activity',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Surface electromyography readings captured during the session.', style: TextStyle(fontSize: 12, color: Color(0xFF5E8A85))),
          const SizedBox(height: 16),
          ...list.map((m) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(m.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0D2B2B))),
                    Text('${m.pct}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: m.color)),
                  ]),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: m.pct / 100,
                    minHeight: 5,
                    backgroundColor: const Color(0xFFCCFBF1),
                    valueColor: AlwaysStoppedAnimation(m.color))),
              ]))),
        ]));
  }

  void _showAISheet(_AIAssessItem item) {
    _showBottomSheet(
      item.label,
      Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFF0FFF4), borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(color: _success, shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 18)),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Passed', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF065F46))),
                    Text('AI Confidence: 97%', style: TextStyle(fontSize: 10, color: Color(0xFF6EE7B7))),
                  ]),
              ])),
          const SizedBox(height: 16),
          Text(item.detail, style: const TextStyle(fontSize: 13, color: Color(0xFF0D2B2B), height: 1.4)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFE6F7F5), borderRadius: BorderRadius.circular(14)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Improvement Suggestion', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _primary)),
                SizedBox(height: 4),
                Text('Continue with the current protocol. This metric will be monitored across future sessions to ensure consistent performance.', style: TextStyle(fontSize: 10, color: Color(0xFF0D2B2B), height: 1.4)),
              ])),
        ]));
  }

  void _showTherapistReportSheet() {
    final list = [
      ['ROM History', '5 sessions tracked'],
      ['Movement Quality', 'EMG + Kinematics'],
      ['Digital Twin', '3D playback ready'],
      ['Progress Report', 'PDF ready to share'],
    ];

    _showBottomSheet(
      'Therapist Detailed Report',
      Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [_primary, Color(0xFF0D9488)]),
              borderRadius: BorderRadius.all(Radius.circular(16))),
            child: const Row(
              children: [
                Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 24),
                SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Data Synchronized', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Encrypted · HIPAA compliant · Just now', style: TextStyle(fontSize: 10, color: Color(0xFFCCFBF1))),
                  ]),
              ])),
          const SizedBox(height: 16),
          ...list.map((item) => Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: const Color(0xFFF0FAFA), borderRadius: BorderRadius.circular(14)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item[0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D2B2B))),
                    Text(item[1], style: const TextStyle(fontSize: 10, color: Color(0xFF5E8A85))),
                  ]),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFFCCFBF1), size: 16),
              ]))),
        ]));
  }

  void _showTimelineSheet(_TimelineItem item) {
    _showBottomSheet(
      item.label,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFF0FAFA), borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Icon(item.icon, color: _primary, size: 20),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D2B2B))),
                    Text('Recorded at ${item.time}', style: const TextStyle(fontSize: 10, color: Color(0xFF5E8A85))),
                  ]),
              ])),
          const SizedBox(height: 16),
          Text(item.detail, style: const TextStyle(fontSize: 13, color: Color(0xFF0D2B2B), height: 1.4)),
        ]));
  }

  void _showRecommendationSheet() {
    _showBottomSheet(
      'Rehabilitation Advice',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDE68A))),
            child: const Text(
              '"Move slightly slower during the final repetitions to improve motor control and reduce fatigue-related errors."',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF92400E), fontStyle: FontStyle.italic, height: 1.4))),
          const SizedBox(height: 16),
          const Text('Why this matters', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0D2B2B))),
          const SizedBox(height: 6),
          const Text(
            'Fatigue-induced velocity errors in the final repetitions can compromise form and increase injury risk. Slowing down activates more deliberate motor pathways, improving long-term neuromuscular adaptation.',
            style: TextStyle(fontSize: 12.5, color: Color(0xFF5E8A85), height: 1.4)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFE6F7F5), borderRadius: BorderRadius.circular(14)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Suggested Protocol Adjustment', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _primary)),
                SizedBox(height: 4),
                Text('For the final 10 reps, reduce movement speed by approximately 20% (target: ~48°/sec). Your physiotherapist has been notified.', style: TextStyle(fontSize: 10, color: Color(0xFF0D2B2B), height: 1.4)),
              ])),
        ]));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Painters & Support Classes
// ─────────────────────────────────────────────────────────────────────────────
class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  final String trendText;
  final Color color;
  final String detail;
  _StatItem(this.icon, this.label, this.value, this.trendText, this.color, this.detail);
}

class _AIAssessItem {
  final String label;
  final String detail;
  _AIAssessItem(this.label, this.detail);
}

class _MuscleDetail {
  final String name;
  final int pct;
  final Color color;
  _MuscleDetail(this.name, this.pct, this.color);
}

class _TimelineItem {
  final String label;
  final String time;
  final IconData icon;
  final String detail;
  _TimelineItem(this.label, this.time, this.icon, this.detail);
}

// Custom painter for recovery spline curve (Area & Line style)
class _RecoveryCurvePainter extends CustomPainter {
  final double progress;
  final bool isExpanded;
  _RecoveryCurvePainter({required this.progress, this.isExpanded = false});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Background Cartesian Grid
    final gridPaint = Paint()
      ..color = const Color(0xFFE6F7F5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final int gridLines = isExpanded ? 5 : 3;
    for (int i = 0; i <= gridLines; i++) {
      double y = h * (i / gridLines);
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Graph Data mapping points (quality 62 -> 95)
    final points = [
      Offset(0, h - (h * 0.62 * 0.85)),
      Offset(w * 0.20, h - (h * 0.71 * 0.85)),
      Offset(w * 0.40, h - (h * 0.78 * 0.85)),
      Offset(w * 0.60, h - (h * 0.84 * 0.85)),
      Offset(w * 0.80, h - (h * 0.90 * 0.85)),
      Offset(w, h - (h * 0.95 * 0.85)),
    ];

    // Build the spline path
    final linePath = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      final pPrev = points[i - 1];
      final pCur = points[i];
      linePath.quadraticBezierTo(
        (pPrev.dx + pCur.dx) / 2,
        (pPrev.dy + pCur.dy) / 2,
        pCur.dx,
        pCur.dy);
    }

    // Clip path using metrics for progressive animation
    final lineMetrics = linePath.computeMetrics();
    final animatedPath = Path();
    for (final metric in lineMetrics) {
      animatedPath.addPath(metric.extractPath(0.0, metric.length * progress), Offset.zero);
    }

    // Draw the gradient filled area beneath the spline
    if (animatedPath.getBounds().width > 0) {
      final fillPath = Path()
        ..addPath(animatedPath, Offset.zero)
        ..lineTo(animatedPath.getBounds().right, h)
        ..lineTo(0, h)
        ..close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          colors: [_secondary.withAlpha((0.25 * 255).round()), _secondary.withAlpha(0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter).createShader(Rect.fromLTWH(0, 0, w, h))
        ..style = PaintingStyle.fill;

      canvas.drawPath(fillPath, fillPaint);
    }

    // Draw the main spline outline
    final linePaint = Paint()
      ..color = _primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = isExpanded ? 3.0 : 2.2
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(animatedPath, linePaint);

    // Draw data markers (dots) on progress milestones
    final dotPaint = Paint()
      ..color = _primary
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    if (progress > 0.1) {
      canvas.drawCircle(points[0], 3, dotPaint);
      canvas.drawCircle(points[0], 3, borderPaint);
    }
    if (progress > 0.5) {
      canvas.drawCircle(points[3], 3, dotPaint);
      canvas.drawCircle(points[3], 3, borderPaint);
    }
    if (progress >= 1.0) {
      canvas.drawCircle(points[5], 3, dotPaint);
      canvas.drawCircle(points[5], 3, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RecoveryCurvePainter old) => old.progress != progress;
}

// Custom painter for Semi-Circular Range of Motion Gauge
class _ROMGaugePainter extends CustomPainter {
  final double angle;
  _ROMGaugePainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final cx = w / 2;
    final cy = h; // Pivot on the bottom center
    final r = math.min(w / 2 - 8, h - 8);

    final trackPaint = Paint()
      ..color = const Color(0xFFCCFBF1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    // Draw full background track (180 deg semi circle)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      math.pi, // Starts at 180 degrees (left side)
      math.pi, // Length is 180 degrees (to right side)
      false,
      trackPaint);

    // Draw active filled progress arc based on angle value
    final activePaint = Paint()
      ..shader = const LinearGradient(colors: [_secondary, _primary]).createShader(
        Rect.fromCircle(center: Offset(cx, cy), radius: r))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final double sweepAngle = (angle / 180).clamp(0.0, 1.0) * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      math.pi,
      sweepAngle,
      false,
      activePaint);

    // Draw needle marker at the tip of the sweep angle
    final double needleRad = math.pi + sweepAngle;
    final nx = cx + r * math.cos(needleRad);
    final ny = cy + r * math.sin(needleRad);

    final needlePaint = Paint()
      ..color = _primary
      ..style = PaintingStyle.fill;

    final needleBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(Offset(nx, ny), 5, needlePaint);
    canvas.drawCircle(Offset(nx, ny), 5, needleBorderPaint);
  }

  @override
  bool shouldRepaint(covariant _ROMGaugePainter old) => old.angle != angle;
}

// ─────────────────────────────────────────────────────────────────────────────
// Syncing Badge Pulsing Dot Widget
// ─────────────────────────────────────────────────────────────────────────────
class BadgePulseDot extends StatefulWidget {
  const BadgePulseDot({super.key});

  @override
  State<BadgePulseDot> createState() => _BadgePulseDotState();
}

class _BadgePulseDotState extends State<BadgePulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, _) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: const Color(0xFF6EE7B7).withAlpha((_pulseAnimation.value * 255).round()),
          shape: BoxShape.circle)));
  }
}
