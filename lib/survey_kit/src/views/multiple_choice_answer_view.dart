import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dissonance_survey_4/getx/extension.dart';

import '../../survey_kit.dart';

class MultipleChoiceAnswerView extends StatefulWidget {
  final QuestionStep questionStep;
  final MultipleChoiceQuestionResult? result;

  MultipleChoiceAnswerView({
    Key? key,
    required this.questionStep,
    required this.result,
  }) : super(key: key);

  @override
  _MultipleChoiceAnswerView createState() => _MultipleChoiceAnswerView();
}

class _MultipleChoiceAnswerView extends State<MultipleChoiceAnswerView> {
  late final DateTime _startDateTime;
  late final MultipleChoiceAnswerFormat _multipleChoiceAnswer;

  List<TextChoice> _selectedChoices = [];

  @override
  void initState() {
    super.initState();
    _multipleChoiceAnswer = widget.questionStep.answerFormat as MultipleChoiceAnswerFormat;
    _selectedChoices = widget.result?.result ?? _multipleChoiceAnswer.defaultSelection;
    _startDateTime = DateTime.now();

    _multipleChoiceAnswer.textChoices.forEach((x) {
      final controller = x.controller;
      if (controller is TextEditingController) {
        controller.addListener(_onListenText);
      }
    });
  }

  @override
  void dispose() {
    _multipleChoiceAnswer.textChoices.forEach((x) {
      final controller = x.controller;
      if (controller is TextEditingController) {
        controller.removeListener(_onListenText);
      }
    });
    super.dispose();
  }

  void _onListenText() {
    _multipleChoiceAnswer.textChoices.forEach((x) {
      final controller = x.controller;
      if (controller is TextEditingController) {
        x.value = controller.text;
      }
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.focusScope?.unfocus();
      },
      child: StepView(
        step: widget.questionStep,
        resultFunction: () => MultipleChoiceQuestionResult(
          id: widget.questionStep.stepIdentifier,
          startDate: _startDateTime,
          endDate: DateTime.now(),
          valueIdentifier: _selectedChoices.map((choices) => choices.value).join(','),
          result: _selectedChoices,
        ),
        isValid: widget.questionStep.isOptional || (_selectedChoices.isNotEmpty && _selectedChoices.every((x) => x.value.isset)),
        title: widget.questionStep.title.isNotEmpty
            ? Text(
                widget.questionStep.title,
                style: Theme.of(context).textTheme.headline2,
                textAlign: TextAlign.center,
              )
            : widget.questionStep.content,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Text(
                  widget.questionStep.text,
                  style: Theme.of(context).textTheme.bodyText2,
                  textAlign: TextAlign.center,
                ),
              ),
              Column(
                children: [
                  Divider(
                    color: Colors.grey,
                  ),
                  ..._multipleChoiceAnswer.textChoices.map((TextChoice tc) => SelectionListTile(
                        onTap: () {
                          setState(
                            () {
                              if (_selectedChoices.contains(tc)) {
                                _selectedChoices.remove(tc);
                              } else {
                                _selectedChoices = [..._selectedChoices, tc];
                              }
                            },
                          );
                        },
                        text: tc.text,
                        isSelected: _selectedChoices.contains(tc),
                        controller: tc.controller,
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
