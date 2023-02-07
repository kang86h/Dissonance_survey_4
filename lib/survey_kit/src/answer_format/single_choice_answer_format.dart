import 'package:json_annotation/json_annotation.dart';

import '../../survey_kit.dart';

part 'single_choice_answer_format.g.dart';

@JsonSerializable()
class SingleChoiceAnswerFormat implements AnswerFormat {
  final List<TextChoice> textChoices;
  final TextChoice? defaultSelection;

  const SingleChoiceAnswerFormat({
    required this.textChoices,
    this.defaultSelection,
  }) : super();

  factory SingleChoiceAnswerFormat.fromJson(Map<String, dynamic> json) =>
      _$SingleChoiceAnswerFormatFromJson(json);
  Map<String, dynamic> toJson() => _$SingleChoiceAnswerFormatToJson(this);
}
