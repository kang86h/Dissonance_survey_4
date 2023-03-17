import 'package:flutter/material.dart';
import 'package:surveykit_example/getx/extension.dart';
import 'package:surveykit_example/main/main_page.dart';
import 'package:surveykit_example/main/model/question_type.dart';

import '../../survey_kit.dart';

class SingleChoiceAnswerView extends StatefulWidget {
  final QuestionStep questionStep;
  final SingleChoiceQuestionResult? result;

  const SingleChoiceAnswerView({
    Key? key,
    required this.questionStep,
    required this.result,
  }) : super(key: key);

  @override
  _SingleChoiceAnswerViewState createState() => _SingleChoiceAnswerViewState();
}

class _SingleChoiceAnswerViewState extends State<SingleChoiceAnswerView> {
  late final DateTime _startDate;
  late final SingleChoiceAnswerFormat _singleChoiceAnswerFormat;
  TextChoice? _selectedChoice;

  @override
  void initState() {
    super.initState();
    _singleChoiceAnswerFormat = widget.questionStep.answerFormat as SingleChoiceAnswerFormat;
    _selectedChoice = widget.result?.result ?? _singleChoiceAnswerFormat.defaultSelection;
    _startDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return StepView(
      step: widget.questionStep,
      resultFunction: () => SingleChoiceQuestionResult(
        id: widget.questionStep.stepIdentifier,
        startDate: _startDate,
        endDate: DateTime.now(),
        valueIdentifier: _selectedChoice?.value ?? '',
        result: _selectedChoice,
      ),
      isValid: widget.questionStep.isOptional || _selectedChoice != null,
      title: widget.questionStep.title.isNotEmpty
          ? Text(
              widget.questionStep.title,
              style: Theme.of(context).textTheme.headline2,
              textAlign: TextAlign.center,
            )
          : widget.questionStep.content,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                widget.questionStep.text,
                style: Theme.of(context).textTheme.bodyText2,
                textAlign: TextAlign.center,
              ),
            ),
            Column(
              children: [
                Divider(
                  color: Colors.cyan,
                ),
                // 조건이 앤서 뷰 내부에 있음
                ..._singleChoiceAnswerFormat.textChoices
                    .asMap()
                    .entries
                    .map((x) => SelectionListTile(
                          text: x.value.text,
                          onTap: () {
                            final question = x.value.value.split("|").firstOrNull.elvis;

                            if (question == QuestionType.hs4q2.name) {
                              MainPage.q2WarmIndex = x.key;
                            } else if (question == QuestionType.hs4q3.name) {
                              MainPage.q3WarmIndex = x.key;
                            } else if (question == QuestionType.hs4q4.name) {
                              MainPage.q4WarmIndex = x.key;
                            }

                            if (_selectedChoice == x.value) {
                              _selectedChoice = null;
                            } else {
                              _selectedChoice = x.value;
                            }
                            setState(() {});
                          },
                          isSelected: _selectedChoice == x.value,
                          child: x.value.child,
                        ))
                    .toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
