import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inteli_rehab/core/constants/app_colors.dart';
import 'package:inteli_rehab/core/constants/onboarding_constants.dart';

import 'package:inteli_rehab/presentation/onboarding/login/login_screen.dart';
import 'package:inteli_rehab/presentation/exercises/widgets/notifications_sheet.dart';
import 'package:inteli_rehab/core/globals.dart';
import 'package:inteli_rehab/presentation/device_connection/connect_device.dart';
import 'package:inteli_rehab/presentation/exercises/live_exercise.dart';
import 'package:inteli_rehab/presentation/exercises/exercise_list.dart';
import 'dart:math' as math;

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  // Helper to open notifications bottom sheet
  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const NotificationsSheet(),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          HapticFeedback.lightImpact();
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        elevation: 8,
        indicatorColor: AppColors.tealCore.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.tealCore),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center, color: AppColors.tealCore),
            label: 'Exercises',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics, color: AppColors.tealCore),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events, color: AppColors.tealCore),
            label: 'Achievements',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.tealCore),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // --- Dynamic AppBar ---
  PreferredSizeWidget _buildAppBar() {
    String titleText = "";
    bool isHome = _selectedIndex == 0;

    switch (_selectedIndex) {
      case 0:
        titleText = "INTELI-REHAB";
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

    if (isHome) {
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', width: 28, height: 28),
            const SizedBox(width: 8),
            Text(
              titleText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        actions: [
          if (globalIsDeviceConnected)
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Center(
                child: Row(
                  children: [
                    Icon(
                      Icons.bluetooth_connected,
                      color: Color(0xFF14B8A6),
                      size: 18,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Connected',
                      style: TextStyle(
                        color: Color(0xFF14B8A6),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          IconButton(
            icon: Badge(
              label: const Text('2'),
              backgroundColor: const Color(0xFFEF4444),
              child: Icon(
                Icons.notifications_outlined,
                color: AppColors.tealCore,
              ),
            ),
            onPressed: _showNotifications,
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = 4; // Switch to Profile tab
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.tealCore.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  OnboardingConstants.defaultProfileImagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Text(
        titleText,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
      ),
      centerTitle: true,
      actions: [
        if (globalIsDeviceConnected)
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Center(
              child: Row(
                children: [
                  Icon(
                    Icons.bluetooth_connected,
                    color: Color(0xFF14B8A6),
                    size: 18,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Connected',
                    style: TextStyle(
                      color: Color(0xFF14B8A6),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_selectedIndex != 4)
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: AppColors.tealCore),
            onPressed: _showNotifications,
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ==========================================
  // TAB 0: PERSONAL REHABILITATION HOME
  // ==========================================
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Welcome Section Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Good Morning,',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        OnboardingConstants.defaultName,
                        style: const TextStyle(
                          fontSize: 22,
                          color: Color(0xFF1F2937),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Ready for today\'s rehabilitation?',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/rehab_welcome_illustration.jpg',
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Today's Rehabilitation Hero Card (Premium Layout with Green Background)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.tealCore, AppColors.tealDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.tealCore.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "TODAY'S REHABILITATION",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white70,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Today's Program",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "3 Assigned Exercises",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "ESTIMATED TIME",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white60,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "18 Minutes",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "RECOVERY FOCUS",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white60,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "Shoulder Mobility",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    if (!globalIsDeviceConnected) {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ExerciseListScreen(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.tealCore,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 16,
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Begin Today's Session",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- NEW COMPONENTS ADDED ---
          const Text(
            "Digital Twin Status",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 10),
          _buildDigitalTwinPreview(),
          const SizedBox(height: 20),

          const Text(
            "Live EMG Signal",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 10),
          _buildEMGGraph(),
          const SizedBox(height: 20),

          const Text(
            "Weekly Goal Progress",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 10),
          _buildProgressBar(),
          const SizedBox(height: 24),
          // ----------------------------

          // 4. Quick Actions (2x2 Grid)
          const Text(
            "Quick Actions",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _buildQuickActionCard(
                imagePath: 'assets/images/recovery_plan.jpeg',
                title: "My Recovery Plan",
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    builder: (context) => Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "My Recovery Plan",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Plan: Upper Limb Joint Mobilization\nDuration: 4 Weeks (Phase 2)\nAssigned by: Dr. Sarah Vance, PT\nWeekly Target: 5 sessions",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4B5563),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.tealCore,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Got it"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              _buildQuickActionCard(
                imagePath: 'assets/images/exercise_library.jpeg',
                title: "Exercise Library",
                onTap: () {
                  setState(() {
                    _selectedIndex = 1; // Jump to Exercises Tab
                  });
                },
              ),
              _buildQuickActionCard(
                imagePath: 'assets/images/progress_history.jpeg',
                title: "Progress History",
                onTap: () {
                  setState(() {
                    _selectedIndex = 2; // Jump to Progress Tab
                  });
                },
              ),
              _buildQuickActionCard(
                imagePath: 'assets/images/help_support.jpeg',
                title: "Help & Support",
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    builder: (context) => Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Help & Support",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "• device issues? Charge the IMU sensors and reconnect via Bluetooth settings.\n• Need therapist assistance? Select 'Contact Therapist Chat' in the Profile Tab.\n• Emergency? Stop exercises immediately if you experience sharp pain.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF4B5563),
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.tealCore,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Dismiss"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 5. Side-by-side Row: Notifications Card & Daily Tip (controls vertical space)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Card
              Expanded(
                child: Container(
                  height: 165,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/update_in_plan.jpeg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.9),
                        ],
                        stops: const [0.2, 1.0],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "UPDATE",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Therapist updated your rehabilitation plan.",
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: _showNotifications,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor: Colors.white,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "View All",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(Icons.chevron_right, size: 14),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Daily Rehabilitation Tip
              Expanded(
                child: Container(
                  height: 165,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/daily_tip.jpeg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.9),
                        ],
                        stops: const [0.2, 1.0],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "DAILY TIP",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Move slowly and avoid sudden arm movements.",
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: const Text("Controlled Movements"),
                                content: const Text(
                                  "Doing exercises too fast increases compensatory movements and limits therapeutic range progress. Keep a slow tempo (~5 seconds per rep) for optimum muscle control.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("OK"),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor: Colors.white,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Learn More",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(Icons.chevron_right, size: 14),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required String imagePath,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
                stops: const [0.4, 1.0],
              ),
            ),
            padding: const EdgeInsets.all(12),
            alignment: Alignment.bottomLeft,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: EXERCISES
  // ==========================================
  Widget _buildExercisesTab() {
    if (globalIsDeviceConnected) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppColors.tealCore,
            ),
            const SizedBox(height: 24),
            const Text(
              'Devices Connected',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your wearable sensors are connected and ready.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExerciseListScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tealCore,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'View Exercises',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sensors_off_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            const Text(
              'Device Not Connected',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Please connect your wearable sensors to access the exercise library and begin your rehabilitation session.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConnectDeviceScreen(),
                  ),
                ).then((_) {
                  setState(() {});
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tealCore,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Connect Device',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: 0.85,
                        strokeWidth: 6,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF14B8A6),
                        ),
                        backgroundColor: const Color(
                          0xFF14B8A6,
                        ).withValues(alpha: 0.1),
                      ),
                      const Text(
                        "85%",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF14B8A6),
                        ),
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
                        "Range of Motion Target",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "85% target achievement achieved.",
                        style: TextStyle(
                          fontSize: 12,
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

          // Custom Painted Weekly ROM target chart
          const Text(
            "Weekly Range of Motion (ROM)",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
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
          const Text(
            "Muscle Contraction (EMG balance)",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
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
                _buildEMGProgressBar(
                  "Biceps Activation",
                  0.78,
                  const Color(0xFF22C55E),
                ),
                const SizedBox(height: 12),
                _buildEMGProgressBar(
                  "Triceps Activation",
                  0.62,
                  const Color(0xFF3B82F6),
                ),
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
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF475569),
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
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
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF475569),
              ),
            ),
            Text(
              "${(value * 100).toInt()}%",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
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
      {
        "title": "Consistency Badge",
        "desc": "Completed 10 consecutive training days",
        "icon": Icons.emoji_events_outlined,
        "color": const Color(0xFFD97706),
        "unlocked": true,
      },
      {
        "title": "Perfect Form",
        "desc": "Maintained 95%+ accuracy in a session",
        "icon": Icons.gps_fixed,
        "color": const Color(0xFF0F766E),
        "unlocked": true,
      },
      {
        "title": "EMG Master",
        "desc": "Achieved full target muscle contraction",
        "icon": Icons.bolt_outlined,
        "color": const Color(0xFF7C3AED),
        "unlocked": true,
      },
      {
        "title": "Early Bird",
        "desc": "Completed training before 9:00 AM",
        "icon": Icons.directions_run_outlined,
        "color": const Color(0xFF2563EB),
        "unlocked": true,
      },
      {
        "title": "ROM Pioneer",
        "desc": "Expanded joint angle beyond 140\u00B0 target",
        "icon": Icons.architecture_outlined,
        "color": const Color(0xFF94A3B8),
        "unlocked": false,
      },
      {
        "title": "Clinical Graduate",
        "desc": "Successfully completed rehab program",
        "icon": Icons.medical_services_outlined,
        "color": const Color(0xFF94A3B8),
        "unlocked": false,
      },
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
                color: Colors.black.withValues(alpha: 0.01),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
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
                  child: Icon(
                    b["icon"] as IconData,
                    size: 28,
                    color: b["color"] as Color,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                b["title"],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked
                      ? const Color(0xFF1E293B)
                      : const Color(0xFF94A3B8),
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
          const SizedBox(height: 10),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.tealCore.withValues(alpha: 0.2),
                width: 3,
              ),
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
          Text(
            OnboardingConstants.defaultName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const Text(
            "patient@inteli-rehab.com",
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Personal profile editor opened.'),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.tealCore),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Edit Profile",
              style: TextStyle(color: AppColors.tealCore, fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),

          _buildProfileOptionCard(Icons.person_outline, "Personal Information"),
          _buildProfileOptionCard(
            Icons.bluetooth_audio,
            "Connected Bluetooth Wearable",
          ),
          _buildProfileOptionCard(
            Icons.notifications_active_outlined,
            "Notification Settings",
          ),
          _buildProfileOptionCard(Icons.lock_outline, "Privacy & HIPAA Policy"),
          _buildProfileOptionCard(
            Icons.support_agent_outlined,
            "Contact Therapist Chat",
          ),
          _buildProfileOptionCard(Icons.info_outline, "About INTELI-REHAB"),

          const SizedBox(height: 16),
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
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEF4444),
                      ),
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Opening $label panel...')));
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- NEW COMPONENT BUILDERS ---
  Widget _buildDigitalTwinPreview() {
    return InkWell(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const LiveExerciseScreen()));
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.tealCore.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.accessibility_new_rounded,
                size: 36,
                color: AppColors.tealCore,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Model Synced",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Real-time posture and muscle strain modeling active.",
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "View Full Twin →",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.tealCore,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEMGGraph() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              4,
              (index) => const Divider(color: Color(0xFFF1F5F9), height: 1),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: CustomPaint(painter: _EMGGraphPainter()),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Weekly Target",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
              Text(
                "75%",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F766E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const LinearProgressIndicator(
              value: 0.75,
              backgroundColor: Color(0xFFF1F5F9),
              color: Color(0xFF0F766E),
              minHeight: 8,
            ),
          ),
        ],
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
      ..color = activeColor.withValues(alpha: 0.06)
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

class _EMGGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.tealCore
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    double width = size.width;
    double height = size.height;

    path.moveTo(0, height / 2);

    for (double i = 0; i < width; i++) {
      double x = i;
      double y =
          height / 2 +
          (math.sin(i * 0.1) *
              (math.Random().nextDouble() > 0.5 ? 15 : 25) *
              math.sin(i * 0.5));
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
