import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inteli_rehab/features/exercise/utils/app_colors.dart';
import 'package:inteli_rehab/features/onboarding/onboarding_constants.dart';
import 'package:inteli_rehab/features/exercise/exercise_overview_screen.dart';
import 'package:inteli_rehab/features/exercise/exercise_list_screen.dart';
import 'package:inteli_rehab/features/exercise/models/exercise.dart';
import 'package:inteli_rehab/features/exercise/data/dummy_data.dart';
import 'package:inteli_rehab/features/auth/login_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _selectedIndex = 0;

  late final List<Exercise> _exercises;

  @override
  void initState() {
    super.initState();
    _exercises = buildDummyExercises();
  }

  // Master Routing to Details
  void _openExerciseDetail(Exercise exercise) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) =>
            ExerciseOverviewScreen(exercise: exercise),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeTab(),
            _buildExercisesTab(),
            _buildProgressTab(),
            _buildAchievementsTab(),
            _buildProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            HapticFeedback.lightImpact();
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.tealCore,
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home, color: AppColors.tealCore),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_outlined),
              activeIcon: Icon(Icons.fitness_center, color: AppColors.tealCore),
              label: 'Exercises',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics, color: AppColors.tealCore),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined),
              activeIcon: Icon(Icons.emoji_events, color: AppColors.tealCore),
              label: 'Achievements',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person, color: AppColors.tealCore),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // --- Dynamic AppBar ---
  PreferredSizeWidget _buildAppBar() {
    String titleText = "";
    bool showHeader = false;

    switch (_selectedIndex) {
      case 0:
        titleText = "Home";
        showHeader = true;
        break;
      case 1:
        titleText = "Exercises";
        break;
      case 2:
        titleText = "Progress Analytics";
        break;
      case 3:
        titleText = "Achievements";
        break;
      case 4:
        titleText = "My Profile";
        break;
    }

    if (showHeader) {
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.tealCore.withOpacity(0.2), width: 1.5),
              ),
              child: ClipOval(
                child: Image.asset(
                  OnboardingConstants.defaultProfileImagePath,
                  fit: BoxFit.cover,
                  width: 38,
                  height: 38,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hello, Kashmala Zeb',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Active recovery program',
                      style: TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Badge(
              label: const Text('2'),
              child: Icon(Icons.notifications_outlined, color: AppColors.tealCore),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rehab schedule synchronized successfully.')),
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      );
    }

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Text(
        titleText,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
      ),
      centerTitle: true,
      actions: [
        if (_selectedIndex != 4)
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: AppColors.tealCore),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rehab schedule synchronized successfully.')),
              );
            },
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ==========================================
  // TAB 0: HOME DASHBOARD
  // ==========================================
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Welcome greeting banner card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.tealCore.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.celebration, color: AppColors.tealCore, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${OnboardingConstants.defaultName.split(' ')[0]}!',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Your rehabilitation plan is ready.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Recovery Streak Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.local_fire_department_outlined, color: Color(0xFFD97706), size: 24),
                ),
                SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "12 Day Recovery Streak",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Keep going! Consistency is key.",
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Today's Session Card (Primary CTA)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.tealCore, AppColors.tealDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.tealCore.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "TODAY'S SESSION",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.0),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Shoulder Flexion Protocol",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Duration: 20 min · 3 Sets x 10 Reps",
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    if (_exercises.isNotEmpty) {
                      _openExerciseDetail(_exercises[0]);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.tealCore,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Start Exercise", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Recovery Progress Ring Card (Tapping takes to Progress tab)
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = 2; // Jump to Progress Tab
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: 0.72,
                          strokeWidth: 6,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.tealCore),
                          backgroundColor: AppColors.tealCore.withOpacity(0.1),
                        ),
                        const Text(
                          "72%",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.tealCore),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "72% Recovery Progress",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Tap to view detailed diagnostics",
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Quick Stats 2x2 Grid
          const Text(
            "Rehab Summary",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard("Exercises", "18 sessions", Icons.fitness_center, const Color(0xFF0F766E)),
              _buildStatCard("Average ROM", "132° Flexion", Icons.rotate_right, const Color(0xFF14B8A6)),
              _buildStatCard("Biceps EMG", "Active", Icons.bolt, const Color(0xFF22C55E)),
              _buildStatCard("Triceps EMG", "Optimal", Icons.offline_bolt_outlined, const Color(0xFF3B82F6)),
            ],
          ),
          const SizedBox(height: 20),

          // Upcoming Reminder
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: AppColors.tealCore, size: 18),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tomorrow · 9:00 AM",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Shoulder Mobility Routine",
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Recent Achievement
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.emoji_events_outlined, color: Color(0xFFD97706), size: 18),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Consistency Badge Unlocked",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Completed 10 consecutive training days.",
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
              Icon(icon, color: color, size: 16),
            ],
          ),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: EXERCISES (Delegates to ExerciseListScreen)
  // ==========================================
  Widget _buildExercisesTab() {
    return const ExerciseListScreen();
  }
  // ==========================================
  // TAB 2: PROGRESS CHARTS
  // ==========================================
  Widget _buildProgressTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ROM Circular Progress Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: 0.85,
                    strokeWidth: 6,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF14B8A6)),
                    backgroundColor: const Color(0xFF14B8A6).withOpacity(0.1),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Range of Motion Target",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "85% target achievement achieved.",
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Custom Painted Weekly ROM target chart
          const Text("Weekly Range of Motion (ROM)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 8),
          Container(
            height: 140,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: CustomPaint(
              painter: DashboardChartPainter(
                points: [0.3, 0.45, 0.4, 0.65, 0.72, 0.8, 0.85],
                activeColor: AppColors.tealCore,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Custom Painted EMG Muscle Balance
          const Text("Muscle Contraction (EMG balance)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildEMGProgressBar("Biceps Activation", 0.78, const Color(0xFF22C55E)),
                const SizedBox(height: 12),
                _buildEMGProgressBar("Triceps Activation", 0.62, const Color(0xFF3B82F6)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Trend Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.trending_up, color: Color(0xFF22C55E), size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Clinical Trend: Range of motion velocity increased by +12.4% over last week's sessions.",
                    style: TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.w600, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEMGProgressBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
            Text("${(value * 100).toInt()}%", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 3: ACHIEVEMENTS
  // ==========================================
  Widget _buildAchievementsTab() {
    final List<Map<String, dynamic>> badges = [
      {"title": "Consistency Badge", "desc": "Completed 10 consecutive training days", "icon": Icons.emoji_events_outlined, "color": const Color(0xFFD97706), "unlocked": true},
      {"title": "Perfect Form", "desc": "Maintained 95%+ accuracy in a session", "icon": Icons.gps_fixed, "color": const Color(0xFF0F766E), "unlocked": true},
      {"title": "EMG Master", "desc": "Achieved full target muscle contraction", "icon": Icons.bolt_outlined, "color": const Color(0xFF7C3AED), "unlocked": true},
      {"title": "Early Bird", "desc": "Completed training before 9:00 AM", "icon": Icons.directions_run_outlined, "color": const Color(0xFF2563EB), "unlocked": true},
      {"title": "ROM Pioneer", "desc": "Expanded joint angle beyond 140\u00B0 target", "icon": Icons.architecture_outlined, "color": const Color(0xFF94A3B8), "unlocked": false},
      {"title": "Clinical Graduate", "desc": "Successfully completed rehab program", "icon": Icons.medical_services_outlined, "color": const Color(0xFF94A3B8), "unlocked": false},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: badges.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final b = badges[index];
        final bool isUnlocked = b["unlocked"];

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.01),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Opacity(
                opacity: isUnlocked ? 1.0 : 0.25,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: (b["color"] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(b["icon"] as IconData, size: 28, color: b["color"] as Color),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                b["title"],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                isUnlocked ? b["desc"] : "Locked Badge",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // TAB 4: PROFILE SETTINGS
  // ==========================================
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar portrait display
          const SizedBox(height: 10),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.tealCore.withOpacity(0.2), width: 3),
            ),
            child: ClipOval(
              child: Image.asset(
                OnboardingConstants.defaultProfileImagePath,
                fit: BoxFit.cover,
                width: 90,
                height: 90,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Kashmala Zeb",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const Text(
            "patient@inteli-rehab.com",
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Personal profile editor opened.')),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.tealCore),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Edit Profile", style: TextStyle(color: AppColors.tealCore, fontSize: 12)),
          ),
          const SizedBox(height: 24),

          // Lists cards settings
          _buildProfileOptionCard(Icons.person_outline, "Personal Information"),
          _buildProfileOptionCard(Icons.bluetooth_audio, "Connected Bluetooth Wearable"),
          _buildProfileOptionCard(Icons.notifications_active_outlined, "Notification Settings"),
          _buildProfileOptionCard(Icons.lock_outline, "Privacy & HIPAA Policy"),
          _buildProfileOptionCard(Icons.support_agent_outlined, "Contact Therapist Chat"),
          _buildProfileOptionCard(Icons.info_outline, "About INTELI-REHAB"),

          const SizedBox(height: 16),
          // Logout Action Card
          Card(
            elevation: 0,
            color: const Color(0xFFFEF2F2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFFFEE2E2)),
            ),
            child: InkWell(
              onTap: () {
                HapticFeedback.heavyImpact();
                // Route back to Login Screen cleanly
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Color(0xFFEF4444), size: 20),
                    SizedBox(width: 14),
                    Text(
                      "Logout Session",
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptionCard(IconData icon, String label) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening $label panel...')),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.tealCore, size: 20),
              const SizedBox(width: 14),
              Text(
                label,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}

// Chart Painter to draw a clean smooth diagnostic curve
class DashboardChartPainter extends CustomPainter {
  final List<double> points;
  final Color activeColor;

  DashboardChartPainter({required this.points, required this.activeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = activeColor
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint fillPaint = Paint()
      ..color = activeColor.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    final double width = size.width;
    final double height = size.height;
    final double stepX = width / (points.length - 1);

    final Path path = Path();
    final Path fillPath = Path();

    path.moveTo(0, height - (points[0] * height));
    fillPath.moveTo(0, height);
    fillPath.lineTo(0, height - (points[0] * height));

    for (int i = 1; i < points.length; i++) {
      final double x = i * stepX;
      final double y = height - (points[i] * height);
      path.lineTo(x, y);
      fillPath.lineTo(x, y);
    }

    fillPath.lineTo(width, height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Draw active dot targets
    final Paint dotPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;
    final Paint dotOutline = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length; i++) {
      final double x = i * stepX;
      final double y = height - (points[i] * height);
      canvas.drawCircle(Offset(x, y), 5.0, dotPaint);
      canvas.drawCircle(Offset(x, y), 5.0, dotOutline);
    }
  }

  @override
  bool shouldRepaint(covariant DashboardChartPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
