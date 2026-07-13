import 'package:flutter/material.dart';
import 'package:inteli_rehab/features/exercise/models/filter_state.dart';
import 'package:inteli_rehab/features/exercise/utils/app_colors.dart';

class FilterSheet extends StatefulWidget {
  final FilterState initial;
  const FilterSheet({super.key, required this.initial});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late Set<String> _difficulties;
  late Set<String> _durations;
  late SortOption _sort;

  @override
  void initState() {
    super.initState();
    _difficulties = {...widget.initial.difficulties};
    _durations = {...widget.initial.durations};
    _sort = widget.initial.sort;
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10, top: 18),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: AppColors.slate.shade800,
      ),
    ),
  );

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.tealCore : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? AppColors.tealCore : AppColors.slate.shade200,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.slate.shade700,
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.slate.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Filter & Sort',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.slate.shade900,
            ),
          ),
          _sectionTitle('Difficulty'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Easy', 'Medium', 'Hard'].map((d) {
              final selected = _difficulties.contains(d);
              return _chip(d, selected, () {
                setState(() {
                  selected ? _difficulties.remove(d) : _difficulties.add(d);
                });
              });
            }).toList(),
          ),
          _sectionTitle('Duration'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['<5 min', '5–10 min', '10+ min'].map((d) {
              final selected = _durations.contains(d);
              return _chip(d, selected, () {
                setState(() {
                  selected ? _durations.remove(d) : _durations.add(d);
                });
              });
            }).toList(),
          ),
          _sectionTitle('Sort By'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(
                'Newest',
                _sort == SortOption.newest,
                () => setState(() => _sort = SortOption.newest),
              ),
              _chip(
                'Alphabetical',
                _sort == SortOption.alphabetical,
                () => setState(() => _sort = SortOption.alphabetical),
              ),
              _chip(
                'Shortest Duration',
                _sort == SortOption.shortestDuration,
                () => setState(() => _sort = SortOption.shortestDuration),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _difficulties.clear();
                      _durations.clear();
                      _sort = SortOption.newest;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: BorderSide(color: AppColors.slate.shade200),
                  ),
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      color: AppColors.slate.shade600,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      FilterState(
                        difficulties: _difficulties,
                        durations: _durations,
                        sort: _sort,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tealCore,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
