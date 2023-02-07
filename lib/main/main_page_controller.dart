import 'dart:html' as html;
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart' as rx;
import 'package:dissonance_survey_4/main/main_page.dart';
import 'package:video_player/video_player.dart';

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

enum VideoStatus {
  empty,
  pause,
  play,
}

class MainPageController extends GetController<MainPageModel> {
  MainPageController({
    required MainPageModel model,
  }) : super(model);

  final AudioPlayer audioPlayer = AudioPlayer();
  final VideoPlayerController videoPlayerController = VideoPlayerController.asset('assets/tutorial.mp4');

  final TextEditingController multipleEditingController = TextEditingController();
  late final TextEditingController textEditingController = TextEditingController()..addListener(onListenText);
  late final SurveyController surveyController = SurveyController(
    onNextStep: (_, __) => _onStep(StepEvent.next),
    onStepBack: (_, __) => _onStep(StepEvent.back),
  );

  late final Rx<VideoStatus> videoStatus = VideoStatus.empty.obs;
  late final Rx<PlayerState> playerState = PlayerState.stopped.obs..bindStream(audioPlayer.onPlayerStateChanged);
  final Rx<double> volume = 1.0.obs;

  final Rx<QuestionType> questionType = QuestionType.none.obs;
  final Rx<int> index = 0.obs;
  final RxBool isSkip = false.obs;
  final RxBool isPlay = false.obs;
  final RxBool isLoad = false.obs;
  final Rx<double> videoBuffered = 0.0.obs;
  final Rx<double> videoPlayed = 0.0.obs;

  @override
  void onInit() async {
    super.onInit();
    await videoPlayerController.initialize();
    videoPlayerController.addListener(_onListenVideo);
    videoStatus.value = VideoStatus.pause;

    playerState.stream
        .where((state) => state == PlayerState.playing)
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
    isLoad.value = true;
    Get.focusScope?.unfocus();

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

    if (state.videoStartedAt.millisecondsSinceEpoch != defaultDateTime.millisecondsSinceEpoch &&
        state.videoEndedAt.millisecondsSinceEpoch == defaultDateTime.millisecondsSinceEpoch &&
        questionType != QuestionType.none) {
      change(state.copyWith(
        videoEndedAt: DateTime.now(),
      ));
    }

    await videoPlayerController.pause();
    await audioPlayer.stop();

    final nextQuestion = state.questions[questionType].elvis.elementAt(index);
    isSkip.value = nextQuestion.isSkip;
    isPlay.value = nextQuestion.volumes.isset;

    if (nextQuestion.file.isset) {
      await audioPlayer.setSource(AssetSource(nextQuestion.file));
      await audioPlayer.seek(Duration.zero);

      if (nextQuestion.isAutoPlay) {
        await audioPlayer.resume();
      }
    }

    isLoad.value = false;
  }

  @override
  void onClose() async {
    await audioPlayer.dispose();
    videoPlayerController.dispose();
    multipleEditingController.dispose();
    textEditingController.dispose();
    [playerState, volume, isSkip, isPlay, isLoad, videoBuffered, videoPlayed].forEach((x) => x.close());
    super.onClose();
  }

  void _onListenVideo() {
    if (videoPlayerController.value.isInitialized) {
      final duration = videoPlayerController.value.duration.inMilliseconds;
      final position = videoPlayerController.value.position.inMilliseconds;

      videoPlayed.value = position / duration;

      videoStatus.value = videoPlayerController.value.isPlaying ? VideoStatus.play : VideoStatus.pause;
    } else {
      videoStatus.value = VideoStatus.empty;
    }
  }

  void onResult(SurveyResult surveyResult) async {
    final gender = surveyResult.results.where((x) => x.id == MainPage.genderIdentifier).firstOrNull?.results.firstOrNull?.valueIdentifier ?? '';
    final age = surveyResult.results.where((x) => x.id == MainPage.ageIdentifier).firstOrNull?.results.firstOrNull?.valueIdentifier ?? '';
    final prequestion =
        surveyResult.results.where((x) => x.id == MainPage.PrequestionIdentifier).firstOrNull?.results.firstOrNull?.valueIdentifier ?? '';

    CollectionReference userCollection = FirebaseFirestore.instance.collection('user');
    final userDocument = await userCollection.add({
      'age': int.tryParse(age) ?? 0,
      'gender': gender,
      'prequestion': (() {
        if (prequestion.contains(',')) {
          final list = prequestion.split(',')..sort();
          return list.join(',');
        }

        return prequestion;
      })(),
      'video_milliseconds': state.getVideoMilliseconds,
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
    videoPlayerController.setVolume(value);
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
    if (!isLoad.value) {
      if (state == PlayerState.playing) {
        await audioPlayer.pause();
      } else if (state == PlayerState.paused) {
        await audioPlayer.resume();
      } else {
        await audioPlayer.seek(Duration.zero);
        await audioPlayer.resume();
      }
    }
  }

  void onPressedVideo() async {
    if (videoStatus.value == VideoStatus.play) {
      await videoPlayerController.pause();
    } else {
      if (state.videoStartedAt.millisecondsSinceEpoch == defaultDateTime.millisecondsSinceEpoch) {
        change(state.copyWith(
          videoStartedAt: DateTime.now(),
        ));
      }

      await videoPlayerController.play();
    }
  }
}
