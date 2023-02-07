import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../survey_kit.dart';

part 'question_step.g.dart';

@JsonSerializable()
class QuestionStep extends Step {
  // 멤버변수 -> 클래스 안에 있는 변수
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(defaultValue: '')
  final String text;
  @JsonKey(ignore: true)
  final Widget content;
  final AnswerFormat answerFormat;

  // int: 0
  // boolean: false
  // String: ''
  // Widget: SizedBox(width: 0, height: 0)

  QuestionStep({
    // 지역변수 -> 함수 안에 있는 변수
    bool isOptional = false,
    String buttonText = '다음으로',
    StepIdentifier? stepIdentifier,
    bool showAppBar = true,
    this.title = '',
    this.text = '',
    this.content = const SizedBox.shrink(),
    required this.answerFormat,
  }) : super(
          stepIdentifier: stepIdentifier,
          isOptional: isOptional,
          buttonText: buttonText,
          showAppBar: showAppBar,
        );

  @override
  Widget createView({required QuestionResult? questionResult}) {
    final key = ObjectKey(this.stepIdentifier.id);

    switch (answerFormat.runtimeType) {
      case IntegerAnswerFormat:
        return IntegerAnswerView(
          key: key,
          questionStep: this,
          result: questionResult as IntegerQuestionResult?,
        );
      case DoubleAnswerFormat:
        return DoubleAnswerView(
          key: key,
          questionStep: this,
          result: questionResult as DoubleQuestionResult?,
          controller: (answerFormat as DoubleAnswerFormat).controller,
          isSkip: (answerFormat as DoubleAnswerFormat).isSkip,
          isPlay: (answerFormat as DoubleAnswerFormat).isPlay,
        );
      case TextAnswerFormat:
        return TextAnswerView(
          key: key,
          questionStep: this,
          result: questionResult as TextQuestionResult?,
        );
      case SingleChoiceAnswerFormat:
        return SingleChoiceAnswerView(
          key: key,
          questionStep: this,
          result: questionResult as SingleChoiceQuestionResult?,
        );
      case MultipleChoiceAnswerFormat:
        return MultipleChoiceAnswerView(
          key: key,
          questionStep: this,
          result: questionResult as MultipleChoiceQuestionResult?,
        );
      case ScaleAnswerFormat:
        return ScaleAnswerView(
          key: key,
          questionStep: this,
          result: questionResult as ScaleQuestionResult?,
        );
      case BooleanAnswerFormat:
        return BooleanAnswerView(
          key: key,
          questionStep: this,
          result: questionResult as BooleanQuestionResult?,
        );
      case DateAnswerFormat:
        return DateAnswerView(
          key: key,
          questionStep: this,
          result: questionResult as DateQuestionResult?,
        );
      case TimeAnswerFormat:
        return TimeAnswerView(
          key: key,
          questionStep: this,
          result: questionResult as TimeQuestionResult?,
        );
      case MultipleDoubleAnswerFormat:
        return MultipleDoubleAnswerView(
          key: key,
          questionStep: this,
          result: questionResult as MultipleDoubleQuestionResult?,
        );
      case ImageAnswerFormat:
        return ImageAnswerView(
          key: key,
          questionStep: this,
          result: questionResult as ImageQuestionResult?,
        );
      default:
        throw AnswerFormatNotDefinedException();
    }
  }

  factory QuestionStep.fromJson(Map<String, dynamic> json) => _$QuestionStepFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionStepToJson(this);
}
