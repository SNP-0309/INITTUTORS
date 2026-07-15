import 'batch.dart';

enum BatchLoadStatus { initial, loading, loaded, error }

class BatchState {
  const BatchState({
    required this.status,
    this.batches = const [],
    this.batch,
    this.roster = const [],
    this.subjects = const [],
    this.classrooms = const [],
    this.count = 0,
    this.currentPage = 1,
    this.hasMore = false,
    this.error,
  });

  final BatchLoadStatus status;
  final List<Batch> batches;
  final Batch? batch;
  final List<BatchStudent> roster;
  final List<Subject> subjects;
  final List<Classroom> classrooms;
  final int count;
  final int currentPage;
  final bool hasMore;
  final String? error;

  const BatchState.initial() : this(status: BatchLoadStatus.initial);

  BatchState copyWith({
    BatchLoadStatus? status,
    List<Batch>? batches,
    Batch? batch,
    List<BatchStudent>? roster,
    List<Subject>? subjects,
    List<Classroom>? classrooms,
    int? count,
    int? currentPage,
    bool? hasMore,
    String? error,
  }) {
    return BatchState(
      status: status ?? this.status,
      batches: batches ?? this.batches,
      batch: batch ?? this.batch,
      roster: roster ?? this.roster,
      subjects: subjects ?? this.subjects,
      classrooms: classrooms ?? this.classrooms,
      count: count ?? this.count,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}
