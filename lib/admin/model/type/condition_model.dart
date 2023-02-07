import 'package:dissonance_survey_4/admin/model/type/condition_type.dart';
import 'package:dissonance_survey_4/admin/model/type/range_type.dart';
import 'package:dissonance_survey_4/getx/get_model.dart';

class ConditionModel extends GetModel {
  ConditionModel({
    required this.field,
    required this.condition,
    required this.range,
    required this.value,
  });

  final dynamic field;
  final ConditionType condition;
  final RangeType range;
  final Iterable<dynamic> value;

  static final ConditionModel _empty = ConditionModel(
    field: null,
    condition: ConditionType.empty,
    range: RangeType.empty,
    value: const [],
  );

  factory ConditionModel.empty() => _empty;

  @override
  bool get isEmpty => this == _empty;

  @override
  ConditionModel copyWith({
    dynamic field,
    ConditionType? condition,
    RangeType? range,
    Iterable<dynamic>? value,
  }) {
    return ConditionModel(
      field: field ?? this.field,
      condition: condition ?? this.condition,
      range: range ?? this.range,
      value: value ?? this.value,
    );
  }

  @override
  List<Object?> get props => [field, condition, range, value];

  @override
  String toString() => 'field: $field condition: $condition range: $range value: $value';
}
