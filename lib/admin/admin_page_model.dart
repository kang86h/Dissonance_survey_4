import 'package:dissonance_survey_4/admin/model/type/condition_model.dart';

import '../getx/get_model.dart';

class AdminPageModel extends GetModel {
  AdminPageModel({
    required this.adminsetting,
    required this.conditions,
  });

  final Iterable adminsetting;
  final Iterable<ConditionModel> conditions;

  static final AdminPageModel _empty = AdminPageModel(
    adminsetting: const {},
    conditions: const [],
  );

  factory AdminPageModel.empty() => _empty;

  @override
  bool get isEmpty => this == _empty;

  @override
  AdminPageModel copyWith({
    Iterable? adminsetting,
    Iterable<ConditionModel>? conditions,
  }) {
    /*
    Stack
    -> 기본 자료형(원시 자료형) 변수
    int, double, bool -> 메모리 고정

    Heap
    -> 참조 자료형(주소값)
    Iterable, String -> 메모리 유동
    */
    // conditions.toList().add(ConditionModel.empty());

    return AdminPageModel(
      adminsetting: adminsetting ?? this.adminsetting,
      conditions: conditions ?? this.conditions,
    );
  }

  @override
  List<Object?> get props => [adminsetting, conditions];

  @override
  String toString() => 'adminsetting: $adminsetting conditions: $conditions';
}
