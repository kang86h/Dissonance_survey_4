import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../survey_kit.dart';
import '../../../survey_kit.dart' as surveystep;

class StepView extends StatelessWidget {
  final surveystep.Step step;
  final Widget title;
  final Widget child;
  final QuestionResult Function() resultFunction;
  final bool isValid;
  final SurveyController? controller;

  const StepView({
    required this.step,
    required this.child,
    required this.title,
    required this.resultFunction,
    this.controller,
    this.isValid = true,
  });

  @override
  Widget build(BuildContext context) {
    final _surveyController = controller ?? context.read<SurveyController>();

    return _content(_surveyController, context);
  }

  Widget _content(SurveyController surveyController, BuildContext context) {
    return SizedBox.expand(
      child: Container(
        color: Theme.of(context).backgroundColor,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: title,
                ),
                child,
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: OutlinedButton(
                    onPressed: isValid || step.isOptional
                        ? () {
                            surveyController.nextStep(context, resultFunction);
                          }
                        : null,
                    child: Text(
                      step.buttonText?.toUpperCase() ?? context.read<Map<String, String>?>()?['next']?.toUpperCase() ?? 'Next',
                      style: TextStyle(
                        color: isValid ? Theme.of(context).primaryColor : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
