import 'package:flutter/material.dart';

import '../../survey_kit.dart';

class CompletionView extends StatelessWidget {
  final CompletionStep completionStep;
  final DateTime _startDate = DateTime.now();
  final String assetPath;

  CompletionView({required this.completionStep, this.assetPath = ""});

  @override
  Widget build(BuildContext context) {
    return StepView(
      step: completionStep,
      resultFunction: () => CompletionStepResult(
        completionStep.stepIdentifier,
        _startDate,
        DateTime.now(),
      ),
      title: Text(completionStep.title,
          style: Theme.of(context).textTheme.headline2),
      child: (() {
        final Widget sizedBox = completionStep.content;
        if (sizedBox is SizedBox &&
            sizedBox.height == 0.0 &&
            sizedBox.width == 0.0) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64.0),
            child: Column(
              children: [
                Text(
                  completionStep.text,
                  style: Theme.of(context).textTheme.bodyText2,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return completionStep.content;
      })(),
    );
  }
}
