import 'package:flutter/material.dart';
import 'package:surveykit_example/getx/extension.dart';
import 'package:surveykit_example/getx/get_rx_impl.dart';

import '../../survey_kit.dart';

class DoubleAnswerView extends StatefulWidget {
  final QuestionStep questionStep;
  final DoubleQuestionResult? result;
  TextEditingController? controller;
  Rx<Color>? color;
  RxBool? isCheck;

  DoubleAnswerView({
    Key? key,
    required this.questionStep,
    required this.result,
    this.controller,
    this.color,
    this.isCheck,
  }) : super(key: key);

  @override
  _DoubleAnswerViewState createState() => _DoubleAnswerViewState();
}

class _DoubleAnswerViewState extends State<DoubleAnswerView> {
  late final DoubleAnswerFormat _doubleAnswerFormat;
  late final DateTime _startDate;

  late bool _isValid = score >= 0;

  double get score => double.tryParse(widget.controller!.value.text) ?? -1;

  @override
  void initState() {
    super.initState();
    _doubleAnswerFormat = widget.questionStep.answerFormat as DoubleAnswerFormat;
    _startDate = DateTime.now();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      widget.controller?.addListener(onListenText);
    });
  }

  @override
  void dispose() {
    widget.controller?.removeListener(onListenText);
    super.dispose();
  }

  void onListenText() {
    setState(() {
      _isValid = score >= 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final child = (() {
      final widgetBuilder = (RxBool? isCheck, Rx<Color>? color) => StepView(
            step: widget.questionStep,
            resultFunction: () => DoubleQuestionResult(
              id: widget.questionStep.stepIdentifier,
              startDate: _startDate,
              endDate: DateTime.now(),
              valueIdentifier: '',
              result: 0,
            ),
            isValid: (isCheck is RxBool && isCheck.value) && (_isValid || widget.questionStep.isOptional),
            title: widget.questionStep.title.isNotEmpty
                ? Text(
                    widget.questionStep.title,
                    style: Theme.of(context).textTheme.headline2,
                    textAlign: TextAlign.center,
                  )
                : widget.questionStep.content,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0.0),
              child: Container(
                width: 500,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      decoration: textFieldInputDecoration(
                        hint: _doubleAnswerFormat.hint,
                      ),
                      style: TextStyle(color: color is Rx<Color> ? color.value : Colors.transparent, fontWeight: FontWeight.bold),
                      readOnly: !(isCheck is RxBool && isCheck.value),
                      controller: widget.controller!,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );

      if (widget.isCheck is RxBool) {
        return ObxValue<RxBool>((isCheck) {
          isCheck.value;
          if (widget.color is Rx<Color>) {
            return ObxValue<Rx<Color>>((color) {
              return widgetBuilder(isCheck, color);
            }, widget.color!);
          }

          return widgetBuilder(isCheck, null);
        }, widget.isCheck!);
      }

      return widgetBuilder(null, null);
    })();

    return GestureDetector(
      onTap: () {
        Get.focusScope?.unfocus();
      },
      child: child,
    );
  }
}
