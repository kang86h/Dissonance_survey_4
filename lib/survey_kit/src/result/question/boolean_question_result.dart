import 'package:json_annotation/json_annotation.dart';

import '../../../survey_kit.dart';

part 'boolean_question_result.g.dart';

@JsonSerializable(explicitToJson: true)
class BooleanQuestionResult extends QuestionResult<BooleanResult?> {
  BooleanQuestionResult({
    required Identifier id,
    required DateTime startDate,
    required DateTime endDate,
    required String valueIdentifier,
    required BooleanResult? result,
  }) : super(
          id: id,
          startDate: startDate,
          endDate: endDate,
          valueIdentifier: valueIdentifier,
          result: result,
        );

  factory BooleanQuestionResult.fromJson(Map<String, dynamic> json) => _$BooleanQuestionResultFromJson(json);

  Map<String, dynamic> toJson() => _$BooleanQuestionResultToJson(this);

  @override
  List<Object?> get props => [id, startDate, endDate, valueIdentifier, result];
}
