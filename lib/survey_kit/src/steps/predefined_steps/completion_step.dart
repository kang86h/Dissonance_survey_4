import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../survey_kit.dart';

part 'completion_step.g.dart';

@JsonSerializable()
class CompletionStep extends Step {
  final String title;
  final String text;
  final String assetPath;

  CompletionStep({
    bool isOptional = false,
    StepIdentifier? stepIdentifier,
    String buttonText = 'End Survey',
    bool showAppBar = true,
    required this.title,
    required this.text,
    this.assetPath = ""
  }) : super(
          stepIdentifier: stepIdentifier,
          isOptional: isOptional,
          buttonText: buttonText,
          showAppBar: showAppBar,
        );

  @override
  Widget createView({required QuestionResult? questionResult}) {
    return CompletionView(completionStep: this, assetPath: assetPath);
  }

  factory CompletionStep.fromJson(Map<String, dynamic> json) =>
      _$CompletionStepFromJson(json);
  Map<String, dynamic> toJson() => _$CompletionStepToJson(this);

  bool operator ==(o) =>
      super == (o) && o is CompletionStep && o.title == title && o.text == text;
  int get hashCode => super.hashCode ^ title.hashCode ^ text.hashCode;
}
