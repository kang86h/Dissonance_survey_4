import 'package:json_annotation/json_annotation.dart';

import '../../../survey_kit.dart';

part 'single_choice_question_result.g.dart';

@JsonSerializable(explicitToJson: true)
class SingleChoiceQuestionResult extends QuestionResult<TextChoice?> {
  SingleChoiceQuestionResult({
    required Identifier id,
    required DateTime startDate,
    required DateTime endDate,
    required String valueIdentifier,
    required TextChoice? result,
  }) : super(
          id: id,
          startDate: startDate,
          endDate: endDate,
          valueIdentifier: valueIdentifier,
          result: result,
        );

  factory SingleChoiceQuestionResult.fromJson(Map<String, dynamic> json) => _$SingleChoiceQuestionResultFromJson(json);

  Map<String, dynamic> toJson() => _$SingleChoiceQuestionResultToJson(this);

  @override
  List<Object?> get props => [id, startDate, endDate, valueIdentifier, result];
}
