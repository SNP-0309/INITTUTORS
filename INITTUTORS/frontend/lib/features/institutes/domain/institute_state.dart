import 'institute.dart';

enum InstituteLoadStatus { initial, loading, loaded, error }

class InstituteState {
  const InstituteState({
    required this.status,
    this.institute,
    this.institutes = const [],
    this.error,
  });

  final InstituteLoadStatus status;
  final Institute? institute;
  final List<Institute> institutes;
  final String? error;

  const InstituteState.initial() : this(status: InstituteLoadStatus.initial);

  InstituteState copyWith({
    InstituteLoadStatus? status,
    Institute? institute,
    List<Institute>? institutes,
    String? error,
  }) {
    return InstituteState(
      status: status ?? this.status,
      institute: institute ?? this.institute,
      institutes: institutes ?? this.institutes,
      error: error,
    );
  }
}
