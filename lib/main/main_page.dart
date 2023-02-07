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
      title: '이 설문조사는 화음을 듣고\n'
          '불협화도 점수를 매기는 조사입니다',
      text: '약 3초간 화음을 듣고\n'
          '화음의 불협화도 점수를 매겨주시면 됩니다\n'
          '협화적인 화음일수록 낮은 점수를\n'
          '불협화적인 화음일수록 높은 점수를 매기세요\n'
          '점수는 숫자로 기입하시거나\n'
          '슬라이더에서 위치를 조절하셔서 매기세요\n'
          '화음에 사용된 음의 갯수에따라 최고점이 다릅니다\n'
          '2음화음 최대 60점\n'
          '3음화음 최대 100점\n'
          '4음화음 최대 140점\n',
      buttonText: '시작',
    );
  }

  QuestionStep getGenderStep() {
    return QuestionStep(
      stepIdentifier: genderIdentifier,
      title: '당신의 성별은 무엇인가요?',
      isOptional: false,
      answerFormat: SingleChoiceAnswerFormat(
        textChoices: [
          TextChoice(text: '남성', value: 'Male'),
          TextChoice(text: '여성', value: 'Female'),
        ],
      ),
    );
  }

  QuestionStep getAgeStep() {
    return QuestionStep(
      stepIdentifier: ageIdentifier,
      title: '당신의 나이는 어떻게 되십니까?',
      answerFormat: IntegerAnswerFormat(),
      isOptional: false,
    );
  }

  QuestionStep getPrequestionStep() {
    return QuestionStep(
      stepIdentifier: PrequestionIdentifier,
      title:
          '당신이 생각하는 불협화음이란 어떤 것입니까?\n옳다고 생각하는 것을 모두 선택해 주세요\n원하시는 답이 없다면 직접 적어주세요.',
      answerFormat: MultipleChoiceAnswerFormat(
        textChoices: [
          TextChoice(text: '1. 거칠게 느껴지는 음', value: '1'),
          TextChoice(text: '2. 한 음으로 합쳐져 들리지 않는 음', value: '2'),
          TextChoice(text: '3. 어울리지 않는 음', value: '3'),
          TextChoice(
              text: '4. 기타',
              value: '',
              controller: controller.multipleEditingController),
        ],
      ),
      isOptional: false,
    );
  }

  InstructionStep getVolume() {
    return InstructionStep(
      title: '테스트에 적절한 볼륨으로 조절해주세요\n'
          '(아이폰, 아이패드 사용자는\n'
          '볼륨버튼을 사용해서 조절해주세요)',
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
                        '재생',
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
                        '볼륨조절',
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
      buttonText: '다음으로',
    );
  }

  InstructionStep getTutirial() {
    return InstructionStep(
      title: '튜토리얼 비디오',
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
      buttonText: '다음으로',
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
                  '$name ${rxIndex.value + 1}번문항.\n지금 들려주는 화음을 듣고 점수를 매겨주세요\n지정된 만점보다 더 큰 점수를 주고 싶으실 경우\n직접 숫자를 입력해주세요.',
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
                            '재생',
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
                            '볼륨조절',
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
                        '아이폰, 아이패드 사용자는\n'
                        '볼륨 버튼을 이용해 조절해주세요',
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
                      '불협화도 점수',
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
        title: '모든 설문이 끝났습니다.',
        text: '참여완료 버튼을 누르시면 모든 설문이 종료됩니다.\n'
            '모든 설문을 종료하시겠습니까?',
        buttonText: '참여완료');
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
