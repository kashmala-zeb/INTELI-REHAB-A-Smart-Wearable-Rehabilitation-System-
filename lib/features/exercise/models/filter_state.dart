enum SortOption { newest, alphabetical, shortestDuration }

class FilterState {
  final Set<String> difficulties; // Easy / Medium / Hard
  final Set<String> durations; // '<5', '5-10', '10+'
  final SortOption sort;

  const FilterState({
    this.difficulties = const {},
    this.durations = const {},
    this.sort = SortOption.newest,
  });

  bool get isActive => difficulties.isNotEmpty || durations.isNotEmpty;

  FilterState copyWith({
    Set<String>? difficulties,
    Set<String>? durations,
    SortOption? sort,
  }) {
    return FilterState(
      difficulties: difficulties ?? this.difficulties,
      durations: durations ?? this.durations,
      sort: sort ?? this.sort,
    );
  }
}
