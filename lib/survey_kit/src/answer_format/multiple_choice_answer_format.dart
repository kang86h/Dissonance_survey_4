import 'package:json_annotation/json_annotation.dart';

import '../../survey_kit.dart';

part 'multiple_choice_answer_format.g.dart';

@JsonSerializable()
class MultipleChoiceAnswerFormat implements AnswerFormat {
  final List<TextChoice> textChoices;
  @JsonKey(defaultValue: const [])
  final List<TextChoice> defaultSelection;

  const MultipleChoiceAnswerFormat({
    required this.textChoices,
    this.defaultSelection = const [],
  }) : super();

  factory MultipleChoiceAnswerFormat.fromJson(Map<String, dynamic> json) =>
      _$MultipleChoiceAnswerFormatFromJson(json);
  Map<String, dynamic> toJson() => _$MultipleChoiceAnswerFormatToJson(this);
}
