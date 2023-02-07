import 'package:flutter/material.dart';
import 'package:dissonance_survey_4/getx/get_rx_impl.dart';

import '../../survey_kit.dart';

class DoubleAnswerView extends StatefulWidget {
  final QuestionStep questionStep;
  final DoubleQuestionResult? result;
  TextEditingController? controller;
  RxBool? isSkip;
  RxBool? isPlay;

  DoubleAnswerView({
    Key? key,
    required this.questionStep,
    required this.result,
    this.controller,
    this.isSkip,
    this.isPlay,
  }) : super(key: key);

  @override
  _DoubleAnswerViewState createState() => _DoubleAnswerViewState();
}

class _DoubleAnswerViewState extends State<DoubleAnswerView> {
  late final DoubleAnswerFormat _doubleAnswerFormat;
  late final DateTime _startDate;

  late bool _isValid = score > 0 || widget.isSkip?.value == true;

  double get score => double.tryParse(widget.controller!.value.text) ?? 0;

  @override
  void initState() {
    super.initState();
    _doubleAnswerFormat =
        widget.questionStep.answerFormat as DoubleAnswerFormat;
    _startDate = DateTime.now();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      widget.controller?.addListener(onListenText);
      widget.controller?.text = widget.result?.result?.toString() ?? '';
    });
  }

  @override
  void dispose() {
    widget.controller?.removeListener(onListenText);
    super.dispose();
  }

  void onListenText() {
    setState(() {
      _isValid = score > 0 || widget.isSkip?.value == true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final child = (() {
      final widgetBuilder = (RxBool? rx) => StepView(
            step: widget.questionStep,
            textEditingController: widget.controller,
            resultFunction: () => DoubleQuestionResult(
              id: widget.questionStep.stepIdentifier,
              startDate: _startDate,
              endDate: DateTime.now(),
              valueIdentifier: widget.controller?.text ?? '',
              result: double.tryParse(widget.controller?.text ?? '') ??
                  _doubleAnswerFormat.defaultValue ??
                  null,
            ),
            isValid: rx is RxBool && rx.value ||
                _isValid ||
                widget.questionStep.isOptional,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: (rx is RxBool && rx.value),
                          onChanged: (value) {
                            if (rx is RxBool) {
                              setState(() {
                                rx.value = value ?? false;
                              });
                            }

                            widget.controller?.clear();
                          },
                        ),
                        Text('평가할 수 없음'),
                      ],
                    ),
                    TextField(
                      decoration: textFieldInputDecoration(
                        hint: _doubleAnswerFormat.hint,
                      ),
                      enabled: !(rx is RxBool && rx.value),
                      controller: widget.controller!,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );

      if (widget.isPlay is RxBool) {
        return ObxValue<RxBool>((isPlay) {
          if (isPlay.value) {
            return ObxValue<RxBool>((isSkip) {
              return widgetBuilder(isSkip);
            }, widget.isSkip!);
          }

          return widgetBuilder(null);
        }, widget.isPlay!);
      }

      return widgetBuilder(null);
    })();

    return GestureDetector(
      onTap: () {
        Get.focusScope?.unfocus();
      },
      child: child,
    );
  }
}
