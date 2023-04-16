import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dissonance_survey_4/getx/extension.dart';
import 'package:dissonance_survey_4/main/model/question_model.dart';
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
  static StepIdentifier prequestionIdentifier =
      StepIdentifier(id: 'prequestion');

  static int q2Index = 8;
  static int q3Index = 15;
  static int q4Index = 22;

  static int q2WarmIndex = -1;
  static int q3WarmIndex = -1;
  static int q4WarmIndex = -1;

  static List<int> q2WarmUpCheckId = [2, 7]..shuffle();
  static List<int> q3WarmUpCheckId = [1, 2, 6]
    ..shuffle(); //협화한걸 고르라 했으면 [1,5,6]
  static List<int> q4WarmUpCheckId = [1, 2, 3, 5]..shuffle();

  static StepIdentifier q2Identifier = StepIdentifier(id: q2Index.toString());
  static StepIdentifier q3Identifier = StepIdentifier(id: q3Index.toString());
  static StepIdentifier q4Identifier = StepIdentifier(id: q4Index.toString());

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
      stepIdentifier: StepIdentifier(id: 'start'),
      title: '이 설문조사는 화음을 듣고\n'
          '불협화한 느낌의 정도를\n'
          '점수로 매기는 조사입니다.',
      text: '1. 약 3초간 화음을 듣고\n'
          '화음의 불협화하게 느껴지는 정도에 따라\n'
          '점수를 매겨주시면 됩니다.\n\n'
          '2. 협화적인 화음일수록 낮은 점수를\n'
          '불협화적인 화음일수록 높은 점수를 매기세요.\n\n'
          '3. 점수는 숫자로 기입하시거나\n'
          '슬라이더에서 위치를 조절하셔서 매기세요.\n\n'
          '4. 화음에 사용된 음의 갯수에따라 최고점이 다릅니다.\n'
          '   2음화음 최대 54점\n'
          '   3음화음 최대 97점\n'
          '   4음화음 최대 137점\n',
      buttonText: '시작',
    );
  }

  InstructionStep getNotice() {
    return InstructionStep(
      stepIdentifier: StepIdentifier(id: 'notice'),
      title: '설문조사는 약 5분에 걸쳐 진행됩니다.',
      text: '설문조사 안에는\n'
          '답변의 신뢰성을 평가하는 문항이 있습니다.\n\n'
          '또한 답변의 일관성을 평가합니다.\n\n'
          '신뢰성과 일관성이 일정 기준치를 충족하지 못하면\n'
          '부적합한 조사결과로 처리되며\n'
          '추가보상을 받으실 수 없습니다.\n\n'
          '진지하게 조사에 임해주시면 감사하겠습니다.\n',
      buttonText: '다음으로',
    );
  }

  InstructionStep getAgreement() {
    return InstructionStep(
      stepIdentifier: StepIdentifier(id: 'agreement'),
      isOption: controller.isOption,
      isOptional: false,
      title: '설문조사 동의서',
      text: '',
      content: controller.rx((state) {
        return ConstrainedBox(
          constraints: BoxConstraints.tightFor(width: 500),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Text('각 사항에 동의하시면 체크하시고 다음으로 넘어가세요.\n동의하시지 않으면 창을 닫아주세요.\n'),
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        maxLines: 3,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        text: TextSpan(children: [
                          TextSpan(
                            text: '1. 이 설문조사의 결과는 ',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          TextSpan(
                              text: '음악의 지각과 인지의 연구 목적으로 ',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                            text: '사용됩니다.',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('결과 공개에 동의하십니까?'),
                    Checkbox(
                      value: state.agrees[0],
                      onChanged: (value) => controller.onChangeAgree(0, value),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        maxLines: 3,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        text: TextSpan(children: [
                          TextSpan(
                            text: '2. 너무 비슷한 값을 여러번 매기시면 각 세션의 ',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          TextSpan(
                              text: '처음으로 ',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                            text: '되돌아가게 됩니다.',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('동의하십니까?'),
                    Checkbox(
                      value: state.agrees[1],
                      onChanged: (value) => controller.onChangeAgree(1, value),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        maxLines: 3,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        text: TextSpan(children: [
                          TextSpan(
                            text:
                                '3. 워밍업 테스트 결과와 모순되는 점수를 매기신 경우 신뢰도가 감소됩니다. 최종 신뢰도가 ',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          TextSpan(
                              text: '80%미만',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                            text: '일 경우 추가보상을 받으실 수 없습니다.',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('동의하십니까?'),
                    Checkbox(
                      value: state.agrees[2],
                      onChanged: (value) => controller.onChangeAgree(2, value),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        maxLines: 3,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        text: TextSpan(children: [
                          TextSpan(
                            text:
                                '4. 같은 음원에 대한 점수의 차이가 만점의 20% 이상일 경우 일관성 점수가 감점됩니다. 일관성 점수가 6점만점에 ',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          TextSpan(
                              text: '5점 미만',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                            text: '일 경우 추가보상을 받으실 수 없습니다.',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('동의하십니까?'),
                    Checkbox(
                      value: state.agrees[3],
                      onChanged: (value) => controller.onChangeAgree(3, value),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        maxLines: 3,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        text: TextSpan(children: [
                          TextSpan(
                            text: '5. 모든 음원은 반드시 ',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          TextSpan(
                              text: '2회',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                            text: '이상 들으셔야 점수를 매기실 수 있습니다.',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '동의하십니까?',
                    ),
                    Checkbox(
                      value: state.agrees[4],
                      onChanged: (value) => controller.onChangeAgree(4, value),
                    ),
                  ],
                ),
                Divider(),
              ],
            ),
          ),
        );
      }),
      buttonText: '다음으로',
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
      stepIdentifier: prequestionIdentifier,
      title:
          '당신이 생각하는 불협화음이란 어떤 것입니까?\n옳다고 생각하는 것을 모두 선택해 주세요.\n원하시는 답이 없다면 직접 적어주세요.',
      answerFormat: MultipleChoiceAnswerFormat(
        textChoices: [
          TextChoice(text: '1. 거칠게 느껴지는 음', value: '1'),
          TextChoice(text: '2. 불쾌한 음', value: '2'),
          TextChoice(text: '3. 탁한 음', value: '3'),
          TextChoice(
              text: '4. 기타(직접 적어주세요\n예시:어울리지 않는 음\n긴장을 유발하는 음 등)',
              value: '',
              controller: controller.multipleEditingController),
        ],
      ),
      isOptional: false,
    );
  }

  InstructionStep getVolume() {
    return InstructionStep(
      stepIdentifier: StepIdentifier(id: 'volume'),
      title: '테스트에 적절한 볼륨으로 조절해주세요.\n'
          '아이폰, 아이패드 사용자는\n'
          '볼륨버튼을 사용해서 조절해주세요.',
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
                          onTap: () =>
                              controller.onPressedState(false, rx.value),
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

  QuestionStep getWarmUpStep(QuestionType questionType, Iterable<int> id) {
    return QuestionStep(
      stepIdentifier: StepIdentifier(id: 'warmUp-${questionType.name}'),
      isOptional: false,
      content: ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: 500),
        child: Center(
          child: Column(
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: {
                        QuestionType.hs4q2: '워밍업 1',
                        QuestionType.hs4q3: '워밍업 2',
                        QuestionType.hs4q4: '워밍업 3',
                      }[questionType]
                          .elvis,
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '다음중 가장 ',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: {
                        QuestionType.hs4q2: '불협화한 화음',
                        QuestionType.hs4q3: '불협화한 화음', //협화한 화음이면 여기서 협화한 화음으로
                        QuestionType.hs4q4: '불협화한 화음',
                      }[questionType]
                          .elvis,
                      style: {
                        QuestionType.hs4q2: TextStyle(
                            fontSize: 26,
                            color: Color.fromRGBO(255, 0, 0, 1),
                            fontWeight: FontWeight.bold),
                        QuestionType.hs4q3: TextStyle(
                            fontSize: 26,
                            color: Color.fromRGBO(255, 0, 0, 1),
                            //협화한 화음이면 (0, 0, 255, 1)
                            fontWeight: FontWeight.bold),
                        QuestionType.hs4q4: TextStyle(
                            fontSize: 26,
                            color: Color.fromRGBO(255, 0, 0, 1),
                            fontWeight: FontWeight.bold),
                      }[questionType],
                    ),
                    TextSpan(
                      text: '을 고르시오',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      answerFormat: SingleChoiceAnswerFormat(
        textChoices: [
          ...id.toList().asMap().entries.map(
                (x) => TextChoice(
                  text: '${x.key + 1}번',
                  value: '${questionType.name}|${x.value}',
                  child: InkWell(
                    onTap: () => controller.onPlay(questionType, x.value),
                    child: controller.rx(
                      (state) {
                        final question = state.questions[questionType].elvis
                            .where((y) => y.id == x.value)
                            .firstOrNull;

                        if (question is QuestionModel) {
                          return controller.playerState.rx(
                            (rx) {
                              return Icon(
                                Icons.play_circle_outline,
                                size: 48,
                                color: rx.value == PlayerState.playing
                                    ? Colors.grey
                                    : Colors.cyan,
                              );
                            },
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  InstructionStep getTutorial() {
    int timeElapsed = 0;
    Stopwatch _stopwatch = Stopwatch();
    void _checkStopwatch() {
      if (timeElapsed + _stopwatch.elapsedMilliseconds >= 15500) {
        controller.isVideoComplete.value = true;
        _stopwatch.stop();
        _stopwatch.reset();
      }
    }

    Stream<int> timerStream() {
      return Stream.periodic(Duration(seconds: 1), (count) {
        _checkStopwatch();
        return count;
      });
    }

    return InstructionStep(
      stepIdentifier: StepIdentifier(id: 'Tutorial'),
      isOption: controller.isVideoComplete,
      isOptional: false,
      title: '튜토리얼 비디오',
      text: '',
      content: controller.videoStatus.rx(
        (rx) {
          if (rx.value == VideoStatus.empty) {
            return CircularProgressIndicator();
          }

          return Column(
            children: [
              Container(
                width: 500,
                child: AspectRatio(
                  aspectRatio:
                      controller.videoPlayerController.value.aspectRatio,
                  child: VideoPlayer(controller.videoPlayerController),
                ),
              ),
              StreamBuilder<int>(
                stream: timerStream(),
                builder: (context, snapshot) {
                  return Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.yellow.withOpacity(1 / 2),
                        shape: BoxShape.circle,
                      ),
                      child: InkWell(
                        onTap: () {
                          controller.onPressedVideo();
                          if (_stopwatch.isRunning) {
                            _stopwatch.stop();
                            timeElapsed += _stopwatch.elapsedMilliseconds;
                            _checkStopwatch();
                          } else {
                            _stopwatch.reset();
                            _stopwatch.start();
                          }
                        },
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
                  );
                },
              ),
            ],
          );
        },
      ),
      buttonText: '다음으로',
    );
  }

  QuestionStep getMainStep(int index) {
    return QuestionStep(
      stepIdentifier: StepIdentifier(id: '$index'),
      content: ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: 500),
        child: Column(
          children: [
            controller.rx((state) {
              return controller.questionType.rx((rxQuestionType) {
                if (rxQuestionType.value == QuestionType.check) {
                  return const SizedBox.shrink();
                }

                final name = rxQuestionType.value.title;
                final entries =
                    state.questions.entries.where((x) => x.key.isLength);
                final keyIndex = entries
                    .map((x) => x.key)
                    .toList()
                    .indexOf(rxQuestionType.value);

                final currentLength = entries
                    .take(keyIndex)
                    .map((x) => x.value.length)
                    .fold<int>(0, (a, c) => a + c);
                final totalLength = entries
                    .map((x) => x.value.length)
                    .fold<int>(0, (a, c) => a + c);

                return controller.index.rx((rxIndex) {
                  return Column(
                    children: [
                      Text(
                        '$name ${rxIndex.value + 1}번문항.(${currentLength + rxIndex.value + 1}/$totalLength)\n화음을 듣고 점수를 매겨주세요.\n만점보다 더 큰 점수를 주고 싶으실 경우\n직접 숫자를 입력해주세요.',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '최소 ',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '2회이상 ',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.red,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '듣고 점수를 매겨주세요.',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  );
                });
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
                          controller.isLoad.rx((rxBool) => rxBool.value
                              ? CircularProgressIndicator()
                              : controller.playerState.rx((rx) {
                                  return InkWell(
                                    onTap: () => controller.onPressedState(
                                        true, rx.value),
                                    child: Icon(
                                      Icons.play_circle_outline,
                                      size: 48,
                                      color: rx.value == PlayerState.playing
                                          ? Colors.grey
                                          : null,
                                    ),
                                  );
                                })),
                          Text(
                            '(재생횟수',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          controller.rx((state) {
                            return controller.questionType.rx((rxQuestionType) {
                              final questionType = rxQuestionType.value;

                              return controller.index.rx((rxIndex) {
                                final index = rxIndex.value;
                                final question =
                                    state.questions[questionType][index];

                                return Text(
                                  '${(question?.volumes.length).elvis}회',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                );
                              });
                            });
                          }),
                          Text(
                            '/2회)',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
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
                        '볼륨 버튼을 이용해 조절해주세요.',
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
                      '불협화도 점수(높을수록 불협화)',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    controller.questionType.rx(
                      (rxKey) {
                        if (rxKey.value == QuestionType.check) {
                          return const SizedBox.shrink();
                        }

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
                                  Slider(
                                    onChanged: (value) =>
                                        controller.onChangedScore(
                                            rxKey.value, rxValue.value, value),
                                    min: 0,
                                    max: question.maxSliderScore,
                                    value: question.sliderScore,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 18.0,
                                      ),
                                      Text(
                                        '0(협화)',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromRGBO(0, 0, 255, 1.0),
                                        ),
                                      ),
                                      /*
                                      Spacer(),
                                      SizedBox(width: question.maxSliderScore > 0 ? (question.maxSliderScore - 20) / 6 : 0),
                                      Text(
                                        '    ${question.maxSliderScore / 2}',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Color.fromRGBO(127, 0, 127, 1.0),
                                        ),
                                      ),
                                       */
                                      Spacer(),
                                      Text(
                                        '(불협화)${question.maxSliderScore}',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromRGBO(255, 0, 0, 1.0),
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
        color: controller.color,
        isCheck: controller.isCheck,
      ),
    );
  }

  QuestionStep getCheckStep(int index) {
    return QuestionStep(
      stepIdentifier: StepIdentifier(id: '${q4Index + 1 + index}'),
      content: ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: 500),
        child: Column(
          children: [
            controller.rx((state) {
              final entries =
                  state.questions.entries.where((x) => x.key.isLength);
              final keyIndex = entries
                  .map((x) => x.key)
                  .toList()
                  .indexOf(QuestionType.check);

              final currentLength = entries
                  .take(keyIndex)
                  .map((x) => x.value.length)
                  .fold<int>(0, (a, c) => a + c);
              final totalLength = entries
                  .map((x) => x.value.length)
                  .fold<int>(0, (a, c) => a + c);

              return Column(
                children: [
                  Text(
                    '일관성 체크 ${index + 1}번문항.(${currentLength + index + 1}/$totalLength)\n화음을 듣고 점수를 매겨주세요.\n만점보다 더 큰 점수를 주고 싶으실 경우\n직접 숫자를 입력해주세요.',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '최소 ',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '2회이상 ',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '듣고 점수를 매겨주세요.',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              );
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
                          controller.isLoad.rx((rxBool) => rxBool.value
                              ? CircularProgressIndicator()
                              : controller.playerState.rx((rx) {
                                  return InkWell(
                                    onTap: () => controller.onPressedState(
                                        true, rx.value),
                                    child: Icon(
                                      Icons.play_circle_outline,
                                      size: 48,
                                      color: rx.value == PlayerState.playing
                                          ? Colors.grey
                                          : null,
                                    ),
                                  );
                                })),
                          Text(
                            '(재생횟수',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          controller.rx((state) {
                            return controller.questionType.rx((rxQuestionType) {
                              final questionType = rxQuestionType.value;

                              return controller.index.rx((rxIndex) {
                                final index = rxIndex.value;
                                final question =
                                    state.questions[questionType][index];

                                return Text(
                                  '${(question?.volumes.length).elvis}회',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                );
                              });
                            });
                          }),
                          Text(
                            '/2회)',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
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
                        '볼륨 버튼을 이용해 조절해주세요.',
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
                final questions = state.questions[QuestionType.check];
                final maxSliderScore = state.questions.values
                    .map((x) => x.map((y) => y.maxSliderScore).reduce(max))
                    .reduce(max);
                final question = questions[index];

                return Column(
                  children: [
                    Text(
                      '불협화도 점수(높을수록 불협화)',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: ((question?.maxSliderScore).elvis +
                              ((maxSliderScore -
                                      (question?.maxSliderScore).elvis) *
                                  0.15)) /
                          maxSliderScore,
                      child: Column(
                        children: [
                          Slider(
                            onChanged: (value) => controller.onChangedScore(
                                QuestionType.check, index, value),
                            min: 0,
                            max: (question?.maxSliderScore).elvis,
                            value: (question?.sliderScore).elvis,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 18.0,
                              ),
                              Text(
                                '0(협화)',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(0, 0, 255, 1.0),
                                ),
                              ),
                              Spacer(),
                              Text(
                                '(불협화)${question?.maxSliderScore.elvis}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(255, 0, 0, 1.0),
                                ),
                              ),
                              SizedBox(
                                width: 12.0,
                              ),
                            ],
                          ),
                        ],
                      ),
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
        color: controller.color,
        isCheck: controller.isCheck,
      ),
    );
  }

  InstructionStep getCheckReliabilityStep() {
    return InstructionStep(
      title: '신뢰성 테스트 결과입니다.',
      content: controller.rx((state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            '''워밍업 첫번째 문항의 신뢰도는 ${(state.q2ReliabilityCount[0] / state.q2ReliabilityCount[1] * 100).toStringAsFixed(0)}%입니다.
워밍업 두번째 문항의 신뢰도는 ${(state.q3ReliabilityCount[0] / state.q3ReliabilityCount[1] * 100).toStringAsFixed(0)}%입니다.
워밍업 세번째 문항의 신뢰도는 ${(state.q4ReliabilityCount[0] / state.q4ReliabilityCount[1] * 100).toStringAsFixed(0)}%입니다.
워밍업 전체의 신뢰도는 ${(state.totalReliabilityCount / state.totalReliabilityTotalcase * 100).toStringAsFixed(0)}%으로 신뢰도 ${state.isReliability ? '적합' : '부적합'} 판정입니다.''',
            textAlign: TextAlign.left,
          ),
        );
      }),
      buttonText: '다음으로',
    );
  }

  InstructionStep getCheckConsistencyStep() {
    return InstructionStep(
      title: '일관성 테스트 결과입니다.',
      content: controller.rx((state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            '''2음화음 일관성 편차는 ${state.q2Consistency.firstOrNull.elvis > 0 ? '+' : ''}${(state.q2Consistency.firstOrNull.elvis).toStringAsFixed(0)}점 ${(state.q2Consistency.secondOrNull.elvis).toStringAsFixed(0)}점 입니다.
3음화음 일관성 편차는 ${state.q3Consistency.firstOrNull.elvis > 0 ? '+' : ''}${(state.q3Consistency.firstOrNull.elvis).toStringAsFixed(0)}점 ${(state.q3Consistency.secondOrNull.elvis).toStringAsFixed(0)}점 입니다.
4음화음 일관성 편차는 ${state.q4Consistency.firstOrNull.elvis > 0 ? '+' : ''}${(state.q4Consistency.firstOrNull.elvis).toStringAsFixed(0)}점 ${(state.q4Consistency.secondOrNull.elvis).toStringAsFixed(0)}점 입니다.
일관성 전체 결과는 기준범위내에 ${state.totalConsistencyCount}개/${1 + 2 + 3}개로 ${state.isConsistency ? '적합' : '부적합'} 판정입니다.''',
          ),
        );
      }),
      buttonText: '다음으로',
    );
  }

  CompletionStep getComplete() {
    return CompletionStep(
      title: '모든 설문이 끝났습니다.',
      content: controller.rx((state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text((state.isReliability && state.isConsistency)
              ? '신뢰성 평가 결과 적합 판정\n일관성 평가 결과 적합 판정으로\n모든 테스트 결과를 신뢰할 수 있겠습니다.\n설문에 참여해 주셔서 감사합니다.'
              : '신뢰성 평가 결과 ${state.isReliability ? '적합' : '부적합'} 판정\n일관성 평가 결과 ${state.isConsistency ? '적합' : '부적합'} 판정으로\n테스트 결과를 신뢰하기 어렵습니다\n유감스럽게도 추가보상을 받으실 수 없습니다.'),
        );
      }),
      text: '',
      buttonText: '참여완료',
    );
  }

  Future<Task> getSampleTask() async {
    return NavigableTask(
      id: TaskIdentifier(),
      steps: [
        getStart(),
        getNotice(),
        getAgreement(),
        getGenderStep(),
        getAgeStep(),
        getPrequestionStep(),
        getVolume(),
        getWarmUpStep(QuestionType.hs4q2, MainPage.q2WarmUpCheckId),
        getWarmUpStep(QuestionType.hs4q3, MainPage.q3WarmUpCheckId),
        getWarmUpStep(QuestionType.hs4q4, MainPage.q4WarmUpCheckId),
        getTutorial(),
        ...List.generate(q4Index + 1, (i) => getMainStep(i)),
        ...List.generate(3, (i) => getCheckStep(i)),
        getCheckReliabilityStep(),
        getCheckConsistencyStep(),
        getComplete(),
      ],
      navigationRules: {
        q2Identifier: ConditionalNavigationRule(
          resultToStepIdentifierMapper: (_) =>
              controller.onCheck(QuestionType.hs4q2, 0, q2Index + 1),
        ),
        q3Identifier: ConditionalNavigationRule(
          resultToStepIdentifierMapper: (_) =>
              controller.onCheck(QuestionType.hs4q3, q2Index + 1, q3Index + 1),
        ),
        q4Identifier: ConditionalNavigationRule(
          resultToStepIdentifierMapper: (_) =>
              controller.onCheck(QuestionType.hs4q4, q3Index + 1, q4Index + 1),
        ),
      },
    );
  }
}
