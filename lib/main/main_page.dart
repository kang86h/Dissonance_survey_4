import 'dart:html' as html;
import 'dart:js';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dissonance_survey_4/getx/extension.dart';
import 'package:video_player/video_player.dart';

import '../getx/get_rx_impl.dart' hide RxBool;
import '../survey_kit/survey_kit.dart';
import 'main_page_controller.dart';
import 'model/question_type.dart';

class MainPage extends GetView<MainPageController> {
  const MainPage({
    Key? key,
  }) : super(key: key);

  static StepIdentifier genderIdentifier = StepIdentifier(id: 'gender');
  static StepIdentifier ageIdentifier = StepIdentifier(id: 'age');
  static StepIdentifier PrequestionIdentifier =
      StepIdentifier(id: 'prequestion');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Task>(
          future: getSampleTask(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData &&
                snapshot.data != null) {
              final task = snapshot.data!;
              return controller.rx((state) {
                return SurveyKit(
                  surveyController: controller.surveyController,
                  onResult: controller.onResult,
                  task: task,
                  showProgress: true,
                  localizations: {
                    'cancel': 'Cancel',
                    'next': 'Next',
                  },
                  themeData: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.fromSwatch(
                      primarySwatch: Colors.cyan,
                    ).copyWith(
                      onPrimary: Colors.white,
                    ),
                    primaryColor: Colors.cyan,
                    backgroundColor: Colors.white,
                    appBarTheme: const AppBarTheme(
                      color: Colors.white,
                      iconTheme: IconThemeData(
                        color: Colors.cyan,
                      ),
                      titleTextStyle: TextStyle(
                        color: Colors.cyan,
                      ),
                    ),
                    iconTheme: const IconThemeData(
                      color: Colors.cyan,
                    ),
                    textSelectionTheme: TextSelectionThemeData(
                      cursorColor: Colors.cyan,
                      selectionColor: Colors.cyan,
                      selectionHandleColor: Colors.cyan,
                    ),
                    cupertinoOverrideTheme: CupertinoThemeData(
                      primaryColor: Colors.cyan,
                    ),
                    outlinedButtonTheme: OutlinedButtonThemeData(
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(
                          Size(150.0, 60.0),
                        ),
                        side: MaterialStateProperty.resolveWith(
                          (Set<MaterialState> state) {
                            if (state.contains(MaterialState.disabled)) {
                              return BorderSide(
                                color: Colors.grey,
                              );
                            }
                            return BorderSide(
                              color: Colors.cyan,
                            );
                          },
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        textStyle: MaterialStateProperty.resolveWith(
                          (Set<MaterialState> state) {
                            if (state.contains(MaterialState.disabled)) {
                              return Theme.of(context)
                                  .textTheme
                                  .button
                                  ?.copyWith(
                                    color: Colors.grey,
                                  );
                            }
                            return Theme.of(context).textTheme.button?.copyWith(
                                  color: Colors.cyan,
                                );
                          },
                        ),
                      ),
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: ButtonStyle(
                        textStyle: MaterialStateProperty.all(
                          Theme.of(context).textTheme.button?.copyWith(
                                color: Colors.cyan,
                              ),
                        ),
                      ),
                    ),
                    textTheme: TextTheme(
                      headline2: TextStyle(
                        fontSize: 24.0,
                        color: Colors.black,
                      ),
                      headline5: TextStyle(
                        fontSize: 22.0,
                        color: Colors.black,
                      ),
                      bodyText2: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                      subtitle1: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                    inputDecorationTheme: InputDecorationTheme(
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  surveyProgressbarConfiguration: SurveyProgressConfiguration(
                    backgroundColor: Colors.white,
                  ),
                );
              });
            }
            return CircularProgressIndicator.adaptive();
          },
        ),
      ),
    );
  }

  InstructionStep getStart() {
    return InstructionStep(
      title: '??? ??????????????? ????????? ??????\n'
          '???????????? ????????? ????????? ???????????????',
      text: '??? 3?????? ????????? ??????\n'
          '????????? ???????????? ????????? ??????????????? ?????????\n'
          '???????????? ??????????????? ?????? ?????????\n'
          '??????????????? ??????????????? ?????? ????????? ????????????\n'
          '????????? ????????? ??????????????????\n'
          '?????????????????? ????????? ??????????????? ????????????\n'
          '????????? ????????? ?????? ??????????????? ???????????? ????????????\n'
          '2????????? ?????? 60???\n'
          '3????????? ?????? 100???\n'
          '4????????? ?????? 140???\n',
      buttonText: '??????',
    );
  }

  QuestionStep getGenderStep() {
    return QuestionStep(
      stepIdentifier: genderIdentifier,
      title: '????????? ????????? ????????????????',
      isOptional: false,
      answerFormat: SingleChoiceAnswerFormat(
        textChoices: [
          TextChoice(text: '??????', value: 'Male'),
          TextChoice(text: '??????', value: 'Female'),
        ],
      ),
    );
  }

  QuestionStep getAgeStep() {
    return QuestionStep(
      stepIdentifier: ageIdentifier,
      title: '????????? ????????? ????????? ?????????????',
      answerFormat: IntegerAnswerFormat(),
      isOptional: false,
    );
  }

  QuestionStep getPrequestionStep() {
    return QuestionStep(
      stepIdentifier: PrequestionIdentifier,
      title:
          '????????? ???????????? ?????????????????? ?????? ?????????????\n????????? ???????????? ?????? ?????? ????????? ?????????\n???????????? ?????? ????????? ?????? ???????????????.',
      answerFormat: MultipleChoiceAnswerFormat(
        textChoices: [
          TextChoice(text: '1. ????????? ???????????? ???', value: '1'),
          TextChoice(text: '2. ??? ????????? ????????? ????????? ?????? ???', value: '2'),
          TextChoice(text: '3. ???????????? ?????? ???', value: '3'),
          TextChoice(
              text: '4. ??????',
              value: '',
              controller: controller.multipleEditingController),
        ],
      ),
      isOptional: false,
    );
  }

  InstructionStep getVolume() {
    return InstructionStep(
      title: '???????????? ????????? ???????????? ??????????????????\n'
          '(?????????, ???????????? ????????????\n'
          '??????????????? ???????????? ??????????????????)',
      text: '',
      content: ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: 500),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: Colors.cyan,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '??????',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      controller.playerState.rx((rx) {
                        return InkWell(
                          onTap: () => controller.onPressedState(rx.value),
                          child: Icon(
                            rx.value == PlayerState.playing
                                ? Icons.pause_circle_outline
                                : Icons.play_circle_outline,
                            size: 48,
                          ),
                        );
                      }),
                      Text(
                        '????????????',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      Icon(
                        Icons.volume_up_rounded,
                        size: 48,
                      ),
                    ],
                  ),
                  controller.volume.rx((rx) {
                    return Slider(
                      onChanged: controller.onChangedVolume,
                      min: 0,
                      max: 1,
                      value: rx.value,
                    ); // score
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
      buttonText: '????????????',
    );
  }

  InstructionStep getTutirial() {
    return InstructionStep(
      title: '???????????? ?????????',
      text: '',
      content: controller.videoStatus.rx((rx) {
        if (rx.value == VideoStatus.empty) {
          return CircularProgressIndicator();
        }

        return Column(
          children: [
            Container(
              width: 500,
              child: AspectRatio(
                aspectRatio: controller.videoPlayerController.value.aspectRatio,
                child: VideoPlayer(controller.videoPlayerController),
              ),
            ),
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(1 / 2),
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  onTap: controller.onPressedVideo,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Icon(
                      rx.value == VideoStatus.play
                          ? Icons.pause_circle_outline
                          : Icons.play_circle_outline,
                      color: Colors.black,
                      size: 48,
                    ),
                  ),
                ),
              ),
            )
          ],
        );
      }),
      buttonText: '????????????',
    );
  }

  QuestionStep getMainStep() {
    return QuestionStep(
      content: ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: 500),
        child: Column(
          children: [
            controller.questionType.rx((rxQuestionType) {
              final name = rxQuestionType.value.title;

              return controller.index.rx((rxIndex) {
                return Text(
                  '$name ${rxIndex.value + 1}?????????.\n?????? ???????????? ????????? ?????? ????????? ???????????????\n????????? ???????????? ??? ??? ????????? ?????? ????????? ??????\n?????? ????????? ??????????????????.',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                );
              });
            }),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                    color: Colors.black,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '??????',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          controller.playerState.rx((rx) {
                            return InkWell(
                              onTap: () => controller.onPressedState(rx.value),
                              child: Icon(
                                rx.value == PlayerState.playing
                                    ? Icons.pause_circle_outline
                                    : Icons.play_circle_outline,
                                size: 48,
                              ),
                            );
                          }),
                          Text(
                            '????????????',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          Icon(
                            Icons.volume_up_rounded,
                            size: 48,
                          ),
                        ],
                      ),
                      Text(
                        '?????????, ???????????? ????????????\n'
                        '?????? ????????? ????????? ??????????????????',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      controller.volume.rx((rx) {
                        return Slider(
                          onChanged: controller.onChangedVolume,
                          min: 0,
                          max: 1,
                          value: rx.value,
                        ); // score
                      }),
                    ],
                  ),
                ),
              ),
            ),
            controller.rx(
              (state) {
                return Column(
                  children: [
                    Text(
                      '???????????? ??????',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    controller.questionType.rx(
                      (rxKey) {
                        final questions = state.questions[rxKey.value];
                        final maxSliderScore = state.questions.values
                            .map((x) =>
                                x.map((y) => y.maxSliderScore).reduce(max))
                            .reduce(max);

                        return controller.index.rx(
                          (rxValue) {
                            final question = questions[rxValue.value]!;

                            return FractionallySizedBox(
                              widthFactor: (question.maxSliderScore +
                                      ((maxSliderScore -
                                              question.maxSliderScore) *
                                          0.15)) /
                                  maxSliderScore,
                              child: Column(
                                children: [
                                  controller.isSkip.rx((rx) {
                                    Get.log('${rx.value}');
                                    final onChanged = (double value) => rx.value
                                        ? null
                                        : controller.onChangedScore(
                                            rxKey.value, rxValue.value, value);

                                    return Slider(
                                      onChanged: onChanged,
                                      min: 0,
                                      max: question.maxSliderScore,
                                      value:
                                          rx.value ? 0 : question.sliderScore,
                                    );
                                  }),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 18.0,
                                      ),
                                      Text(
                                        '0',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Spacer(),
                                      SizedBox(
                                          width: question.maxSliderScore > 0
                                              ? (question.maxSliderScore - 20) /
                                                  6
                                              : 0),
                                      Text(
                                        '${question.maxSliderScore / 2}',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        '${question.maxSliderScore}',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 12.0,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      answerFormat: DoubleAnswerFormat(
        controller: controller.textEditingController,
        isSkip: controller.isSkip,
        isPlay: controller.isPlay,
      ),
    );
  }

  CompletionStep getComplete() {
    return CompletionStep(
        title: '?????? ????????? ???????????????.',
        text: '???????????? ????????? ???????????? ?????? ????????? ???????????????.\n'
            '?????? ????????? ?????????????????????????',
        buttonText: '????????????');
  }

  Future<Task> getSampleTask() async {
    return NavigableTask(
      id: TaskIdentifier(),
      steps: [
        getStart(),
        getGenderStep(),
        getAgeStep(),
        getPrequestionStep(),
        getVolume(),
        getTutirial(),
        ...Iterable.generate(20, (_) => getMainStep()),
        getComplete(),
      ],
    );
  }
}
