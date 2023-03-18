import 'package:flutter/material.dart';
import 'package:dissonance_survey_4/getx/get_rx_impl.dart';

import '../../survey_kit.dart';

class InstructionView extends StatefulWidget {
  final InstructionStep instructionStep;
  RxBool? isOption;
  // bool -> true, false
  // true -> false: UI Rebuild (X)
  // Rxbool -> (true, false <- 관찰) UI Rebuild(O)

  InstructionView({
    required this.instructionStep,
    this.isOption,
  });

  @override
  State<InstructionView> createState() => _InstructionViewState();
}

class _InstructionViewState extends State<InstructionView> {
  late final DateTime _startDate;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final widgetBuilder = (RxBool? rx) => StepView(
          step: widget.instructionStep,
          title: Text(
            widget.instructionStep.title,
            style: Theme.of(context).textTheme.headline2,
            textAlign: TextAlign.left,
          ),
          resultFunction: () => InstructionStepResult(
            widget.instructionStep.stepIdentifier,
            _startDate,
            DateTime.now(),
          ),
          isValid: rx == null || rx.value,
          child: (() {
            final Widget sizedBox = widget.instructionStep.content;
            if (sizedBox is SizedBox && sizedBox.height == 0.0 && sizedBox.width == 0.0) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Text(
                  widget.instructionStep.text,
                  style: Theme.of(context).textTheme.bodyText2,
                  textAlign: TextAlign.left,
                ),
              );
            }

            return widget.instructionStep.content;
          })(),
        );

    if (widget.isOption is RxBool) {
      return ObxValue<RxBool>((isOption) {
        return widgetBuilder(isOption);
      }, widget.isOption!);
    }

    return widgetBuilder(null);
  }
}
