/*
import 'dart:html' as html;
import 'dart:math';

/*
import 'package:assets_audio_player/assets_audio_player.dart' hide PlayerState;
import 'package:audioplayers/audioplayers.dart';
*/

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart' as rx;
import 'package:surveykit_example/main/main_page.dart';

import '../getx/extension.dart';
import '../getx/get_controller.dart';
import '../getx/get_rx_impl.dart';
import '../survey_kit/survey_kit.dart';
import 'main_page_model.dart';
import 'model/question_model.dart';
import 'model/question_type.dart';

enum StepEvent {
  next,
  back,
}

class MainPageController extends GetController<MainPageModel> {
  MainPageController({
    required MainPageModel model,
  }) : super(model);

  final AssetsAudioPlayer audioPlayer = AssetsAudioPlayer.newPlayer();
  late final AssetsAudioPlayer player;

  late final TextEditingController multipleEditingController = TextEditingController();
  late final TextEditingController textEditingController = TextEditingController()..addListener(onListenText);
  late final SurveyController surveyController = SurveyController(
    onNextStep: (_, __) => _onStep(StepEvent.next),
    onStepBack: (_, __) => _onStep(StepEvent.back),
  );

  late final Rx<PlayerState> playerState = PlayerState.stop.obs..bindStream(audioPlayer.playerState);
  final Rx<double> volume = 1.0.obs;

  final Rx<QuestionType> questionType = QuestionType.none.obs;
  final Rx<int> index = 0.obs;
  final RxBool isSkip = false.obs;
  final RxBool isPlay = false.obs;

  @override
  void onInit() async {
    super.onInit();

    final player = AssetsAudioPlayer.newPlayer();
    this.player = player;
    player.onErrorDo = (e) {
      Get.log('e: ${e.error}');
      Get.log('e: ${e.error.message}');
    };
    player.open(
      Audio("assets/tutorial.mp4"),
      autoStart: true,
      showNotification: true,
      volume: 1,
    );
    player.isPlaying.listen((event) {
      Get.log('event: $event');
    });

    playerState.stream
        .where((state) => state == PlayerState.play)
        .withLatestFrom3<QuestionType, int, double, Map>(questionType.stream, index.stream, volume.stream, (state, questionType, index, volume) {
      final question = this.state.questions[questionType].elvis.elementAt(index);
      final startedAt = question.isRecord && question.startedAt.length == question.endedAt.length ? [...question.startedAt, DateTime.now()] : null;

      return {
        QuestionType: questionType,
        int: index,
        QuestionModel: question.copyWith(
          volumes: [
            ...question.volumes,
            volume,
          ],
          startedAt: startedAt,
        ),
      };
    }).listen((map) {
      final question = map[QuestionModel];

      if (question is QuestionModel) {
        onChange(
          map[QuestionType] as QuestionType,
          map[int] as int,
          volumes: question.volumes,
          startedAt: question.startedAt,
        );
      }

      isPlay.value = true;
    });
    onChangedVolume(1 / 2);
  }

  void _onStep(StepEvent event) async {
    Get.focusScope?.unfocus();
    await player.play();

    var questionType = this.questionType.value;
    var index = this.index.value;
    final question = state.questions[questionType].elvis.elementAt(index);
    final endedAt = question.isRecord && question.startedAt.length > question.endedAt.length ? [...question.endedAt, DateTime.now()] : null;

    onChange(
      questionType,
      index,
      score: isSkip.value ? 0 : null,
      isSkip: isSkip.value,
      endedAt: endedAt,
    );

    final keyIndex = state.questions.keys.toList().indexOf(questionType);

    if (event == StepEvent.next) {
      if (index < state.questions[questionType].elvis.length - 1) {
        index = index + 1;
      } else if (keyIndex < state.questions.keys.length - 1) {
        questionType = state.questions.keys.elementAt(keyIndex + 1);
        index = 0;
      }
    } else if (event == StepEvent.back) {
      if (index > 0) {
        index = index - 1;
      } else if (keyIndex > 0) {
        final prevKey = state.questions.keys.elementAt(keyIndex - 1);

        questionType = prevKey;
        index = state.questions[prevKey].elvis.length - 1;
      }
    }

    this.index.value = index;
    this.questionType.value = questionType;

    await audioPlayer.stop();

    final nextQuestion = state.questions[questionType].elvis.elementAt(index);
    isSkip.value = nextQuestion.isSkip;
    isPlay.value = nextQuestion.volumes.isset;
    if (nextQuestion.file.isset) {
      await audioPlayer.open(
        Audio('assets/${nextQuestion.file}'),
        autoStart: true,
      );
      await audioPlayer.seek(Duration.zero);

      if (nextQuestion.isAutoPlay) {
        await audioPlayer.play();
      }
    }
  }

  @override
  void onClose() async {
    await audioPlayer.dispose();
    [playerState, volume, isSkip, isPlay].forEach((x) => x.close());
    multipleEditingController.dispose();
    textEditingController.dispose();
    super.onClose();
  }

  void onResult(SurveyResult surveyResult) async {
    final gender = surveyResult.results.where((x) => x.id == MainPage.genderIdentifier).firstOrNull?.results.firstOrNull?.valueIdentifier ?? '';
    final age = surveyResult.results.where((x) => x.id == MainPage.ageIdentifier).firstOrNull?.results.firstOrNull?.valueIdentifier ?? '';
    final prequestion =
        surveyResult.results.where((x) => x.id == MainPage.PrequestionIdentifier).firstOrNull?.results.firstOrNull?.valueIdentifier ?? '';

    CollectionReference userCollection = FirebaseFirestore.instance.collection('user');
    final userDocument = await userCollection.add({
      'age': age,
      'gender': gender,
      'prequestion': prequestion,
      'createdAt': DateTime.now(),
    });

    CollectionReference resultCollection = FirebaseFirestore.instance.collection('result');
    await resultCollection.add({
      'user_id': userDocument.id,
      'question': state.toJson(),
      'createdAt': DateTime.now(),
    });

    html.window.open('https://naver.com', '_self');
  }

  void onChangedScore(QuestionType questionType, int index, double value) {
    // 메인 페이지 모델을 변경하는 함수 -> change
    // Iterable<MapEntry(Key, Value)>
    /*
    [
      MapEntry(QuestionType.none, [
        QuestionModel(),
        QuestionModel(),
        QuestionModel(),
      ]),

      ->


      MapEntry(QuestionType.none, {
        0: QuestionModel(),
        1: QuestionModel(),
        2: QuestionModel(),
      }),


      MapEntry(QuestionType.q1, [
        QuestionModel(),
        QuestionModel(),
        QuestionModel(),
      ]),
    ],
    */

    final questionType = this.questionType.value;
    final index = this.index.value;

    final questionModel = state.questions[questionType][index];

    if (questionModel is QuestionModel && questionModel.volumes.isset) {
      onChange(questionType, index, score: value);
      textEditingController.text = value.toStringAsFixed(0);
    }
  }

  void onChange(
    QuestionType questionType,
    int index, {
    String? file,
    double? score,
    bool? isSkip,
    double? maxSliderScore,
    double? maxTextScore,
    Iterable<double>? volumes,
    Iterable<DateTime>? startedAt,
    Iterable<DateTime>? endedAt,
  }) {
    change(
      state.copyWith(
        questions: Map.fromEntries({
          ...state.questions.entries.map((x) => MapEntry(
                x.key,
                x.key == questionType
                    ? [
                        ...x.value.toList().asMap().entries.map((z) => z.key == index
                            ? z.value.copyWith(
                                file: file,
                                score: score,
                                isSkip: isSkip,
                                maxSliderScore: maxSliderScore,
                                maxTextScore: maxTextScore,
                                volumes: volumes,
                                startedAt: startedAt,
                                endedAt: endedAt,
                              )
                            : z.value),
                      ]
                    : x.value,
              )),
        }),
      ),
    );
  }

  void toAdmin() async {
    // await Get.toNamed('/admin');
  }

  void onChangedVolume(double value) {
    audioPlayer.setVolume(value);
    volume.value = value;
  }

  void onListenText() {
    final questionType = this.questionType.value;
    final index = this.index.value;

    final text = double.tryParse(textEditingController.value.text) ?? 0;
    // 50
    final questionModel = state.questions[questionType][index];

    if (questionModel is QuestionModel && questionModel.volumes.isset) {
      // questionModel.maxTextScore 60
      // questionModel.maxSliderScore 100 -> UI쪽에서 maxSliderScore보다 작은 값을 할당

      final maxScore = max(questionModel.maxTextScore, questionModel.maxSliderScore);

      if (text > 0) {
        // 스킵하지 않고 텍스트 컨트롤러의 값이 있을 때
        final score = maxScore > 0 ? min(maxScore, text) : text;
        onChange(questionType, index, isSkip: false, score: score);

        if (text != score) {
          textEditingController.text = score.toString();
          textEditingController.selection = TextSelection(
            baseOffset: score.toString().length,
            extentOffset: score.toString().length,
          );
        }
      } else if (!isSkip.value && questionModel.score > 0) {
        // 이전, 다음 스텝으로 진행했을 때
        textEditingController.text = questionModel.score.toStringAsFixed(0);

        final length = questionModel.score.toString().length;
        if (length > 0 && !questionModel.isSkip) {
          textEditingController.selection = TextSelection(
            baseOffset: length,
            extentOffset: length,
          );
        }
      }
    } else {
      textEditingController.clear();
    }
  }

  void onPressedState(PlayerState state) async {
    if (state == PlayerState.play) {
      await audioPlayer.pause();
    } else if (state == PlayerState.pause) {
      await audioPlayer.play();
    } else {
      await audioPlayer.seek(Duration.zero);
      await audioPlayer.play();
    }
  }
}

*/