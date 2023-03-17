import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:surveykit_example/getx/get_rx_impl.dart';

import '../../../survey_kit.dart';

part 'instruction_step.g.dart';

@JsonSerializable(explicitToJson: true)
class InstructionStep extends Step {
  final String title;
  final String text;
  final Widget content;

  // const, final, static
  // const: 컴파일 이전에 값이 정해짐
  // final: 컴파일 이후에 값이 정해짐
  // static: 어디서든지 공유 가능한 전역변수

  InstructionStep({
    required this.title,
    this.text = '',
    this.content = const SizedBox.shrink(),
    RxBool? isOption,
    bool isOptional = true,
    String buttonText = 'Next',
    StepIdentifier? stepIdentifier,
    bool? canGoBack,
    bool? showProgress,
    bool showAppBar = true,
  }) : super(
          stepIdentifier: stepIdentifier,
          isOption: isOption,
          isOptional: isOptional,
          buttonText: buttonText,
          canGoBack: canGoBack ?? true,
          showProgress: showProgress ?? true,
          showAppBar: showAppBar,
        );

  @override
  Widget createView({required QuestionResult? questionResult}) {
    return InstructionView(
      instructionStep: this,
      isOption: isOption,
    );
  }

  factory InstructionStep.fromJson(Map<String, dynamic> json) => _$InstructionStepFromJson(json);

  Map<String, dynamic> toJson() => _$InstructionStepToJson(this);

  bool operator ==(o) => super == (o) && o is InstructionStep && o.title == title && o.text == text;

  int get hashCode => super.hashCode ^ title.hashCode ^ text.hashCode;
}
