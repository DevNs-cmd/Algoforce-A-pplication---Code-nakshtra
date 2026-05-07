enum PhaseState { done, active, upcoming }

class PhaseItem {
  const PhaseItem({
    required this.id,
    required this.description,
    required this.completed,
  });

  final String id;
  final String description;
  final bool completed;

  PhaseItem copyWith({bool? completed}) {
    return PhaseItem(
      id: id,
      description: description,
      completed: completed ?? this.completed,
    );
  }
}

class Phase {
  const Phase({
    required this.id,
    required this.monthRange,
    required this.title,
    required this.state,
    required this.items,
    required this.target,
  });

  final String id;
  final String monthRange;
  final String title;
  final PhaseState state;
  final List<PhaseItem> items;
  final String target;

  int get completedCount => items.where((item) => item.completed).length;
  double get completion => items.isEmpty ? 0 : completedCount / items.length;

  Phase copyWith({List<PhaseItem>? items}) {
    return Phase(
      id: id,
      monthRange: monthRange,
      title: title,
      state: state,
      items: items ?? this.items,
      target: target,
    );
  }
}
