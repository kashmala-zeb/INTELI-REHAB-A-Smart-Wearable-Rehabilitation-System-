import 'dart:math';
import 'package:flutter/material.dart';
import 'package:inteli_rehab/data/datasources/local/dummy_data.dart';
import 'package:inteli_rehab/domain/entities/exercise.dart';
import 'package:inteli_rehab/domain/entities/filter_state.dart';
import 'package:inteli_rehab/core/constants/app_colors.dart';
import 'package:inteli_rehab/core/constants/app_strings.dart';
import 'package:inteli_rehab/core/utils/snackbar_utils.dart';
import 'package:inteli_rehab/presentation/exercises/widgets/empty_state.dart';
import 'package:inteli_rehab/presentation/exercises/widgets/exercise_card.dart';
import 'package:inteli_rehab/presentation/exercises/widgets/filter_sheet.dart';
import 'package:inteli_rehab/presentation/exercises/exercise_overview.dart';


class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen>
    with SingleTickerProviderStateMixin {
  int _selectedCategoryIndex = 0;



  late List<Exercise> _exercises;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  FilterState _filterState = const FilterState();
  late final String _motivationMessage;

  late AnimationController _progressAnimController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _exercises = buildDummyExercises();
    _motivationMessage =
        AppConstants.motivationalMessages[Random().nextInt(
          AppConstants.motivationalMessages.length,
        )];

    _progressAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _progressAnimation = Tween<double>(begin: 0, end: _overallProgress())
        .animate(
          CurvedAnimation(
            parent: _progressAnimController,
            curve: Curves.easeOutCubic,
          ),
        );
    _progressAnimController.forward();

    _searchController.addListener(() {
      setState(
        () => _searchQuery = _searchController.text.trim().toLowerCase(),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _progressAnimController.dispose();
    super.dispose();
  }

  double _overallProgress() {
    if (_exercises.isEmpty) return 0;
    final completed = _exercises
        .where((e) => e.status == ExerciseStatus.completed)
        .length;
    return completed / _exercises.length;
  }

  int get _completedCount =>
      _exercises.where((e) => e.status == ExerciseStatus.completed).length;

  List<Exercise> get _filteredExercises {
    var list = List<Exercise>.from(_exercises);

    // Category filter
    final selectedCategory =
        AppConstants.categories[_selectedCategoryIndex].name;
    if (selectedCategory != 'All') {
      list = list.where((e) => e.category == selectedCategory).toList();
    }

    // Search filter (case-insensitive, partial match on title + category)
    if (_searchQuery.isNotEmpty) {
      list = list.where((e) {
        return e.title.toLowerCase().contains(_searchQuery) ||
            e.category.toLowerCase().contains(_searchQuery) ||
            e.description.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Difficulty filter
    if (_filterState.difficulties.isNotEmpty) {
      list = list
          .where((e) => _filterState.difficulties.contains(e.difficulty))
          .toList();
    }

    // Duration filter
    if (_filterState.durations.isNotEmpty) {
      list = list.where((e) {
        final d = e.durationMinutes;
        return _filterState.durations.any((bucket) {
          if (bucket == '<5 min') return d < 5;
          if (bucket == '5–10 min') return d >= 5 && d <= 10;
          if (bucket == '10+ min') return d > 10;
          return false;
        });
      }).toList();
    }

    // Sort
    switch (_filterState.sort) {
      case SortOption.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.alphabetical:
        list.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.shortestDuration:
        list.sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
        break;
    }

    return list;
  }

  void _updateExercise(String id, {double? progress, ExerciseStatus? status}) {
    setState(() {
      final index = _exercises.indexWhere((e) => e.id == id);
      if (index != -1) {
        _exercises[index] = _exercises[index].copyWith(
          progress: progress,
          status: status,
        );
      }
    });
  }

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

  Future<void> _showFilterSheet() async {
    final result = await showModalBottomSheet<FilterState>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => FilterSheet(initial: _filterState),
    );
    if (result != null) {
      setState(() => _filterState = result);
      if (!mounted) return;
      AppSnackbar.success(context, 'Filter Applied');
    }
  }


  @override
  Widget build(BuildContext context) {
    final filtered = _filteredExercises;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Image.asset('assets/images/logo.png', width: 28, height: 28),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRecoveryCard(),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 20),
              _buildCategoryChips(),
              const SizedBox(height: 24),
              _buildMotivationBanner(),
              const SizedBox(height: 28),
              _buildSectionHeader(),
              const SizedBox(height: 16),
              _buildExerciseListOrEmptyState(filtered),
            ],
          ),
        ),
      ),
    );
  }


  // ---------------------------------------------------------------------


  // ---------------------------------------------------------------------
  // RECOVERY CARD
  // ---------------------------------------------------------------------
  Widget _buildRecoveryCard() {
    final total = _exercises.length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Header Pic showing the smart wearable sensor on the arm
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/header_pic.jpeg',
              width: 86,
              height: 86,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          // 2. Recovery Status Labels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Recovery',
                  style: TextStyle(
                    color: AppColors.slate.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Excellent Progress',
                  style: TextStyle(
                    color: AppColors.tealCore,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "You've completed $_completedCount of $total sessions today.",
                  style: TextStyle(
                    color: AppColors.slate.shade600,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // 3. Circular Progress bar indicator
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              final value = _progressAnimation.value;
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.tealCore.withValues(alpha: 0.04),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 6,
                      backgroundColor: AppColors.slate.shade100,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.tealCore,
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    '${(value * 100).round()}%',
                    style: TextStyle(
                      color: AppColors.slate.shade900,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }


  // ---------------------------------------------------------------------
  // SEARCH BAR
  // ---------------------------------------------------------------------
  Widget _buildSearchBar() {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.slate.shade900.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: AppColors.slate.shade100, width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.slate.shade500, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: TextStyle(fontSize: 14, color: AppColors.slate.shade800),
              decoration: InputDecoration(
                hintText: 'Search targeted exercises...',
                hintStyle: TextStyle(
                  color: AppColors.slate.shade400,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            InkWell(
              onTap: () {
                _searchController.clear();
                AppSnackbar.info(context, 'Search Cleared');
              },
              child: Icon(
                Icons.close_rounded,
                color: AppColors.slate.shade400,
                size: 20,
              ),
            ),
          VerticalDivider(
            color: AppColors.slate.shade200,
            indent: 14,
            endIndent: 14,
            width: 24,
          ),
          Material(
            color: _filterState.isActive
                ? AppColors.tealCore.withValues(alpha: 0.16)
                : AppColors.tealCore.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _showFilterSheet,
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: Icon(
                  Icons.tune_rounded,
                  color: AppColors.tealCore,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // CATEGORY CHIPS
  // ---------------------------------------------------------------------
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: AppConstants.categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          final category = AppConstants.categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: isSelected
                    ? LinearGradient(
                        colors: [AppColors.tealBright, AppColors.tealCore],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.tealCore.withValues(alpha: 0.32),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: AppColors.slate.shade900.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    setState(() => _selectedCategoryIndex = index);
                    AppSnackbar.info(
                      context,
                      'Category Changed: ${category.name}',
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.transparent : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : AppColors.slate.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          category.icon,
                          size: 16,
                          color: isSelected
                              ? Colors.white
                              : AppColors.slate.shade600,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          category.name,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.slate.shade700,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------
  // MOTIVATION BANNER
  // ---------------------------------------------------------------------
  Widget _buildMotivationBanner() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0FDF4), Color(0xFFECFDF5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDCFCE7), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF16A34A).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.15),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: Color(0xFF16A34A),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Committed to Recovery',
                      style: TextStyle(
                        color: Color(0xFF14532D),
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '4-Day Streak',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 9.5,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _motivationMessage,
                    key: ValueKey(_motivationMessage),
                    style: TextStyle(
                      color: const Color(0xFF166534).withValues(alpha: 0.9),
                      fontSize: 12,
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

  // ---------------------------------------------------------------------
  // SECTION HEADER
  // ---------------------------------------------------------------------
  Widget _buildSectionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Assigned Exercises",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.slate.shade900,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Icon(
              Icons.medical_information_outlined,
              size: 14,
              color: AppColors.slate.shade400,
            ),
            const SizedBox(width: 6),
            Text(
              'Therapeutic tasks customized by your clinical team',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.slate.shade500,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // EXERCISE LIST / EMPTY STATES
  // ---------------------------------------------------------------------
  Widget _buildExerciseListOrEmptyState(List<Exercise> filtered) {
    if (_exercises.isEmpty) {
      return EmptyState(
        icon: Icons.event_busy_rounded,
        title: 'No Assigned Exercises',
        subtitle: 'Your therapist has not assigned any exercises yet.',
      );
    }

    if (filtered.isEmpty && _searchQuery.isNotEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No Exercise Found',
        subtitle: "We couldn't find any exercise matching your search.",
        actionLabel: 'Clear Search',
        onAction: () {
          _searchController.clear();
          AppSnackbar.info(context, 'Search Cleared');
        },
      );
    }

    if (filtered.isEmpty) {
      final categoryName = AppConstants.categories[_selectedCategoryIndex].name;
      return EmptyState(
        icon: Icons.fitness_center_rounded,
        title: 'No Exercises Available',
        subtitle: 'No exercises available in the "$categoryName" category.',
        actionLabel: 'Show All',
        onAction: () {
          setState(() => _selectedCategoryIndex = 0);
        },
      );
    }

    return Column(
      children: filtered.map((exercise) {
        return ExerciseCard(
          key: ValueKey(exercise.id),
          exercise: exercise,
          onTapCard: () => _openExerciseDetail(exercise),
          onStart: () => _updateExercise(
            exercise.id,
            status: ExerciseStatus.inProgress,
            progress: 0.1,
          ),
          onResume: () {
            _openExerciseDetail(exercise);
          },
          onRepeat: () {
            _updateExercise(
              exercise.id,
              status: ExerciseStatus.inProgress,
              progress: 0.0,
            );
            AppSnackbar.success(context, 'Repeating ${exercise.title}');
          },
        );
      }).toList(),
    );
  }


}

