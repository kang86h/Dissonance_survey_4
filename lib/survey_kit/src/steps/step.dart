import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../survey_kit.dart';

abstract class Step {
  final StepIdentifier stepIdentifier;
  @JsonKey(defaultValue: false)
  final bool isOptional;
  @JsonKey(defaultValue: 'Next')
  final String? buttonText;
  final bool canGoBack;
  final bool showProgress;
  final bool showAppBar;

  Step({
    StepIdentifier? stepIdentifier,
    this.isOptional = false,
    this.buttonText = 'Next',
    this.canGoBack = true,
    this.showProgress = true,
    this.showAppBar = true,
  }) : stepIdentifier = stepIdentifier ?? StepIdentifier();

  Widget createView({required QuestionResult? questionResult});

  factory Step.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type == 'intro') {
      return InstructionStep.fromJson(json);
    } else if (type == 'question') {
      return QuestionStep.fromJson(json);
    } else if (type == 'completion') {
      return CompletionStep.fromJson(json);
    }
    throw StepNotDefinedException();
  }

  Map<String, dynamic> toJson();

  bool operator ==(o) =>
      o is Step &&
      o.stepIdentifier == stepIdentifier &&
      o.isOptional == isOptional &&
      o.buttonText == buttonText;
  int get hashCode =>
      stepIdentifier.hashCode ^ isOptional.hashCode ^ buttonText.hashCode;
}
