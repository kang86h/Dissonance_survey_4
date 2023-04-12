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

  static bool disabled = false;

  final AudioPlayer audioPlayer = AudioPlayer();
  final VideoPlayerController videoPlayerController =
      VideoPlayerController.asset('assets/tutorial.mp4');

  final TextEditingController multipleEditingController =
      TextEditingController();
  late final TextEditingController textEditingController =
      TextEditingController()..addListener(onListenText);
  late final SurveyController surveyController = SurveyController(
    onNextStep: (_, __) => _onStep(StepEvent.next),
    onStepBack: (_, __) => _onStep(StepEvent.back),
  );

  late final Rx<VideoStatus> videoStatus = VideoStatus.empty.obs;
  late final Rx<PlayerState> playerState = PlayerState.stopped.obs
    ..bindStream(audioPlayer.onPlayerStateChanged.delayWhen((x) {
      return rx.Rx.timer(x, Duration(seconds: [PlayerState.stopped, PlayerState.completed].contains(x) ? 1 : 0));
    }));
  final Rx<double> volume = 1.0.obs;
  final Rx<QuestionType> questionType = QuestionType.none.obs;
  final Rx<int> index = 0.obs;
  final Rx<Color> color = Colors.transparent.obs;
  final RxBool isCheck = false.obs;
  final RxBool isLoad = false.obs;
  final RxBool isOption = false.obs;
  final RxBool isVideoComplete = false.obs;
  final Rx<double> videoBuffered = 0.0.obs;
  final Rx<double> videoPlayed = 0.0.obs;

  String get uid => Uri.dataFromString(html.window.location.href)
      .queryParameters['uid']
      .elvis;

  void onInit() async {
    super.onInit();
    await videoPlayerController.initialize();
    videoPlayerController.addListener(_onListenVideo);
    videoStatus.value = VideoStatus.pause;

    playerState.stream
        .where((state) => state == PlayerState.playing)
        .withLatestFrom3<QuestionType, int, double, Map>(
            questionType.stream, index.stream, volume.stream,
            (state, questionType, index, volume) {
      final question =
          this.state.questions[questionType].elvis.elementAt(index);
      final startedAt = question.isRecord &&
              question.startedAt.length == question.endedAt.length
          ? [...question.startedAt, DateTime.now()]
          : null;

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
        isCheck.value = question.volumes.isCheck;

        onChange(
          map[QuestionType] as QuestionType,
          map[int] as int,
          volumes: question.volumes,
          startedAt: question.startedAt,
        );
      }
    });
    onChangedVolume(1 / 2);
  }

  void _onStep(StepEvent event) async {
    isLoad.value = false;
    Get.focusScope?.unfocus();

    var isReset = false;
    var questionType = this.questionType.value;
    var index = this.index.value;
    final question = state.questions[questionType].elvis.elementAt(index);
    final endedAt =
        question.isRecord && question.startedAt.length > question.endedAt.length
            ? [...question.endedAt, DateTime.now()]
            : null;

    onChange(
      questionType,
      index,
      endedAt: endedAt,
    );

    final keyIndex = state.questions.keys.toList().indexOf(questionType);

    if (event == StepEvent.next) {
      if (index < state.questions[questionType].elvis.length - 1) {
        index = index + 1;
      } else if (questionType != QuestionType.check) {
        final questions = state.questions[questionType].elvis;
        final scores = questions.map((x) => x.score);
        final avg = scores.fold<double>(0, (a, c) => a + c) ~/ scores.length;
        final acc = (questions.firstOrNull?.maxSliderScore).elvis ~/ 10;
        final sorted = scores.toList()..sort();
        final range = List.generate((scores.length / 2).ceil(),
            (i) => sorted[i + (scores.length / 2).floor()] - sorted[i]);

        if (((scores.any((x) => x > avg + acc || x < avg - acc)) &&
                (range.every((y) => y > acc / 2))) ||
            keyIndex == 0) {
          // 다음 퀘스천 타입으로 넘어갈 수 있을 때
          if (keyIndex < state.questions.keys.length - 1) {
            questionType = state.questions.keys.elementAt(keyIndex + 1);
          } else {
            questionType = QuestionType.check;
          }
        } else {
          isReset = true;
        }

        index = 0;
      }
    } else if (event == StepEvent.back) {
      if (index > 0) {
        index = index - 1;
      }
    }

    this.index.value = index;
    disabled = index == 0 || questionType == QuestionType.check;
    this.questionType.value = questionType;

    final videoEndedAt = state.videoStartedAt.millisecondsSinceEpoch !=
                defaultDateTime.millisecondsSinceEpoch &&
            state.videoEndedAt.millisecondsSinceEpoch ==
                defaultDateTime.millisecondsSinceEpoch &&
            questionType != QuestionType.none
        ? DateTime.now()
        : null;

    change(state.copyWith(
      questions: isReset
          ? {
              ...state.questions.map((k, v) {
                if (k == questionType) {
                  return MapEntry(k, [
                    ...v.map((x) => x.copyWith(
                          score: x.maxSliderScore / 2,
                          volumes: [],
                          startedAt: [],
                          endedAt: [],
                        )),
                  ]);
                }

                return MapEntry(k, v);
              }),
            }
          : null,
      videoEndedAt: videoEndedAt,
    ));

    await videoPlayerController.pause();
    await audioPlayer.stop();

    final nextQuestion = state.questions[questionType].elvis.elementAt(index);
    isCheck.value = nextQuestion.volumes.isCheck;

    if (nextQuestion.file.isset) {
      await audioPlayer.setSource(AssetSource(nextQuestion.file));
      await audioPlayer.seek(Duration.zero);

      if (nextQuestion.isAutoPlay) {
        await audioPlayer.resume();
      }
    }

    // 강제로 onListenText를 호출하여 텍스트 컨트롤러 값 초기화
    onListenText(true);

    isLoad.value = false;
  }

  @override
  void onClose() async {
    await audioPlayer.dispose();
    videoPlayerController.dispose();
    multipleEditingController.dispose();
    textEditingController.dispose();
    [
      playerState,
      volume,
      isCheck,
      isLoad,
      isOption,
      isVideoComplete,
      videoBuffered,
      videoPlayed
    ].forEach((x) => x.close());
    super.onClose();
  }

  void _onListenVideo() {
    if (videoPlayerController.value.isInitialized) {
      final duration = videoPlayerController.value.duration.inMilliseconds;
      final position = videoPlayerController.value.position.inMilliseconds;

      videoPlayed.value = position / duration;

      videoStatus.value = videoPlayerController.value.isPlaying
          ? VideoStatus.play
          : VideoStatus.pause;
    } else {
      videoStatus.value = VideoStatus.empty;
    }
  }

  void onResult(SurveyResult surveyResult) async {
    if (state.isReliability && state.isConsistency) {
      final gender = surveyResult.results
              .where((x) => x.id == MainPage.genderIdentifier)
              .firstOrNull
              ?.results
              .firstOrNull
              ?.valueIdentifier ??
          '';
      final age = surveyResult.results
              .where((x) => x.id == MainPage.ageIdentifier)
              .firstOrNull
              ?.results
              .firstOrNull
              ?.valueIdentifier ??
          '';
      final prequestion = surveyResult.results
              .where((x) => x.id == MainPage.prequestionIdentifier)
              .firstOrNull
              ?.results
              .firstOrNull
              ?.valueIdentifier ??
          '';

      CollectionReference userCollection =
          FirebaseFirestore.instance.collection('user');
      final userDocument = await userCollection.add({
        'uid': uid,
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

      CollectionReference resultCollection =
          FirebaseFirestore.instance.collection('result');
      await resultCollection.add(
        {
          'user_id': userDocument.id,
          'question': state.toJson(),
          'createdAt': DateTime.now(),
          'q2ReliabilityCount': state.q2ReliabilityCount[0],
          'q2ReliabilityLength': state.q2ReliabilityCount[1],
          'q3ReliabilityCount': state.q3ReliabilityCount[0],
          'q3ReliabilityLength': state.q3ReliabilityCount[1],
          'q4ReliabilityCount': state.q4ReliabilityCount[0],
          'q4ReliabilityLength': state.q4ReliabilityCount[1],
          'totalReliabilityCount': state.totalReliabilityCount,
          'totalReliabilityLength': state.totalReliabilityTotalcase,
          'q2ConsistencyPlus': state.q2Consistency.firstOrNull.elvis,
          'q2ConsistencyMinus': state.q2Consistency.secondOrNull.elvis,
          'q3ConsistencyPlus': state.q3Consistency.firstOrNull.elvis,
          'q3ConsistencyMinus': state.q3Consistency.secondOrNull.elvis,
          'q4ConsistencyPlus': state.q4Consistency.firstOrNull.elvis,
          'q4ConsistencyMinus': state.q4Consistency.secondOrNull.elvis,
          'totalConsistencyCount': state.totalConsistencyCount,
          'totalConsistencyLength': 6,
        },
      );

      //await Get.toNamed('/complete');
      html.window.open('https://ko.research.net/r/JF2TNYL?uid=$uid', '_self');
    } else {
      // 신뢰성 체크 실패 시
      final gender = surveyResult.results
              .where((x) => x.id == MainPage.genderIdentifier)
              .firstOrNull
              ?.results
              .firstOrNull
              ?.valueIdentifier ??
          '';
      final age = surveyResult.results
              .where((x) => x.id == MainPage.ageIdentifier)
              .firstOrNull
              ?.results
              .firstOrNull
              ?.valueIdentifier ??
          '';
      final prequestion = surveyResult.results
              .where((x) => x.id == MainPage.prequestionIdentifier)
              .firstOrNull
              ?.results
              .firstOrNull
              ?.valueIdentifier ??
          '';

      CollectionReference userCollection =
          FirebaseFirestore.instance.collection('user');
      final userDocument = await userCollection.add({
        'uid': uid,
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

      CollectionReference resultCollection =
          FirebaseFirestore.instance.collection('result');
      await resultCollection.add(
        {
          'user_id': userDocument.id,
          'question': state.toJson(),
          'createdAt': DateTime.now(),
          'q2ReliabilityCount': state.q2ReliabilityCount[0],
          'q2ReliabilityLength': state.q2ReliabilityCount[1],
          'q3ReliabilityCount': state.q3ReliabilityCount[0],
          'q3ReliabilityLength': state.q3ReliabilityCount[1],
          'q4ReliabilityCount': state.q4ReliabilityCount[0],
          'q4ReliabilityLength': state.q4ReliabilityCount[1],
          'totalReliabilityCount': state.totalReliabilityCount,
          'totalReliabilityLength': state.totalReliabilityTotalcase,
          'q2ConsistencyPlus': state.q2Consistency.firstOrNull.elvis,
          'q2ConsistencyMinus': state.q2Consistency.secondOrNull.elvis,
          'q3ConsistencyPlus': state.q3Consistency.firstOrNull.elvis,
          'q3ConsistencyMinus': state.q3Consistency.secondOrNull.elvis,
          'q4ConsistencyPlus': state.q4Consistency.firstOrNull.elvis,
          'q4ConsistencyMinus': state.q4Consistency.secondOrNull.elvis,
          'totalConsistencyCount': state.totalConsistencyCount,
          'totalConsistencyLength': 6,
        },
      );

      html.window.open('https://ko.research.net/r/JF8RP9B?uid=$uid', '_self');
    }
  }

  void onChangedScore(QuestionType questionType, int index, double value) {
    final questionType = this.questionType.value;
    final index = this.index.value;

    final questionModel = state.questions[questionType][index];

    if (questionModel is QuestionModel && questionModel.volumes.isCheck) {
      onChange(questionType, index, score: value);

      textEditingController.text = value.floor().toString();
      final ratioR = (sin(((value - (questionModel.maxSliderScore * 0.5)) /
                      questionModel.maxSliderScore) *
                  pi) *
              0.5) +
          0.5;
      final r = max(2, (min(1, ratioR) * 255).floor());
      color.value = Color.fromRGBO(r, 0, 257 - r, 1);
    }
  }

  void onChange(
    QuestionType questionType,
    int index, {
    String? file,
    double? score,
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
                        ...x.value
                            .toList()
                            .asMap()
                            .entries
                            .map((z) => z.key == index
                                ? z.value.copyWith(
                                    file: file,
                                    score: score,
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

  void onChangedVolume(double value) {
    audioPlayer.setVolume(value);
    videoPlayerController.setVolume(value);
    volume.value = value;
  }

  void onListenText([bool? isStep]) {
    final questionType = this.questionType.value;
    final index = this.index.value;

    final text = textEditingController.value.text.isset
        ? double.tryParse(textEditingController.value.text) ?? -1.0
        : -1.0;
    final questionModel = state.questions[questionType][index];

    if (questionModel is QuestionModel && questionModel.volumes.isCheck) {
      final maxScore =
          max(questionModel.maxTextScore, questionModel.maxSliderScore);

      if (text >= 0) {
        // 스킵하지 않고 텍스트 컨트롤러의 값이 있을 때
        final score = maxScore > 0 ? min(maxScore, text) : text;
        onChange(questionType, index, score: score);

        if (text != score) {
          textEditingController.text = score.toString();
          textEditingController.selection = TextSelection(
            baseOffset: score.toString().length,
            extentOffset: score.toString().length,
          );
        }

        final ratioR = (sin(((min(score, questionModel.maxSliderScore) -
                            (questionModel.maxSliderScore * 0.5)) /
                        questionModel.maxSliderScore) *
                    pi) *
                0.5) +
            0.5;
        final r = max(2, (min(1, ratioR) * 255).floor());
        color.value = Color.fromRGBO(r, 0, 257 - r, 1);
      } else if (questionModel.score >= 0) {
        // 이전, 다음 스텝으로 진행했을 때
        textEditingController.text = questionModel.score.floor().toString();

        final length = questionModel.score.toString().length;
        if (length > 0) {
          textEditingController.selection = TextSelection(
            baseOffset: length,
            extentOffset: length,
          );
        }

        if (!isStep.elvis) {
          onChangedScore(questionType, index, 0);
        }
      } else {
        textEditingController.clear();
      }
    } else {
      textEditingController.clear();
    }
  }

  void onPressedState(bool isIgnore, PlayerState state) async {
    if (!isLoad.value) {
      if (state == PlayerState.playing) {
        if (!isIgnore) {
          await audioPlayer.pause();
        }
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
      if (state.videoStartedAt.millisecondsSinceEpoch ==
          defaultDateTime.millisecondsSinceEpoch) {
        change(state.copyWith(
          videoStartedAt: DateTime.now(),
        ));
      }

      await videoPlayerController.play();
    }
  }

  StepIdentifier onCheck(QuestionType type, int start, int end) {
    final questionType = this.questionType.value;

    if (questionType == type) {
      Get.snackbar(
        '비슷한 값이 너무 많습니다',
        '이 단계의 처음부터 다시 테스트를 시작합니다',
        duration: const Duration(seconds: 5),
      );
      disabled = true;

      return StepIdentifier(id: start.toString());
    }

    return StepIdentifier(id: end.toString());
  }

  StepIdentifier onComplete() {
    return StepIdentifier(id: 'complete');
  }

  void onPlay(QuestionType questionType, int id) async {
    if (playerState.value != PlayerState.playing) {
      final question = state.questions[questionType].elvis
          .where((x) => x.id == id)
          .firstOrNull;
      // final source = AssetSource((question?.file).elvis);
      final source = audioPlayer.source;


      if (question is QuestionModel) {
        // 현재 재생중인 문항을 한 번 더 클릭했을 때
        if (source is AssetSource && source.path == question.file) {
          await audioPlayer.resume();
          // 현재 재생중이 아닌 다른 문항을 클릭했을 때
        } else if (question.file.isset) {
          await audioPlayer.setSource(AssetSource(question.file));
          await audioPlayer.seek(Duration.zero);
          await audioPlayer.resume();
        }
      }

    }
  }

  void onChangeAgree(int index, bool? value) {
    change(
      state.copyWith(
        agrees: [
          ...state.agrees
              .toList()
              .asMap()
              .entries
              .map((x) => x.key == index ? value.elvis : x.value),
        ],
      ),
    );

    isOption.value = state.agrees.every((x) => x);
  }
}
