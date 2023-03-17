import 'dart:math';

import 'package:surveykit_example/getx/extension.dart';

import '../../getx/get_model.dart';

class QuestionModel extends GetModel {
  QuestionModel({
    required this.id,
    required this.file,
    required this.score,
    required this.maxSliderScore,
    required this.maxTextScore,
    required this.volumes,
    required this.isAutoPlay,
    required this.isRecord,
    required this.isWarmUpCheck,
    required this.isMiddleCheck,
    required this.isFinalCheck,
    required this.startedAt,
    required this.endedAt,
    required this.totalMilliseconds,
    required this.prequestion,
  });

  final int id;
  final String file;
  final double score;
  final double maxSliderScore;
  final double maxTextScore;
  final Iterable<double> volumes;
  final bool isAutoPlay;
  final bool isRecord;
  final bool isWarmUpCheck;
  final bool isMiddleCheck;
  final bool isFinalCheck;
  final Iterable<DateTime> startedAt;
  final Iterable<DateTime> endedAt;
  final int totalMilliseconds;
  final Iterable<String> prequestion;

  double get sliderScore => min(score, maxSliderScore);

  int get getTotalMilliseconds {
    final length = min(startedAt.length, endedAt.length);
    final total =
        Iterable.generate(length, (i) => endedAt.elementAt(i).difference(startedAt.elementAt(i))).fold<Duration>(Duration.zero, (a, c) => a + c);
    return total.inMilliseconds;
  }

  static final QuestionModel _empty = QuestionModel(
    id: 0,
    file: '',
    score: 0,
    maxSliderScore: 0,
    maxTextScore: 0,
    volumes: const [],
    isAutoPlay: false,
    isRecord: false,
    isWarmUpCheck: false,
    isMiddleCheck: false,
    isFinalCheck: false,
    startedAt: const [],
    endedAt: const [],
    totalMilliseconds: 0,
    prequestion: [],
  );

  static final QuestionModel _volume = _empty.copyWith(
    file: 'volume.mp3',
    isAutoPlay: true,
  );

  static final QuestionModel _prequestion = _empty.copyWith(
    prequestion: [],
  );

  factory QuestionModel.empty() => _empty;

  factory QuestionModel.volume() => _volume;

  factory QuestionModel.prequestion() => _prequestion;

  @override
  bool get isEmpty => this == _empty;

  String get header => file.split('/').lastOrNull.elvis.split('.').firstOrNull.elvis;

  @override
  QuestionModel copyWith({
    int? id,
    String? file,
    double? score,
    double? maxSliderScore,
    double? maxTextScore,
    Iterable<double>? volumes,
    bool? isAutoPlay,
    bool? isRecord,
    bool? isWarmUpCheck,
    bool? isMiddleCheck,
    bool? isFinalCheck,
    Iterable<DateTime>? startedAt,
    Iterable<DateTime>? endedAt,
    int? totalMilliseconds,
    Iterable<String>? prequestion,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      file: file ?? this.file,
      score: score ?? this.score,
      maxSliderScore: maxSliderScore ?? this.maxSliderScore,
      maxTextScore: maxTextScore ?? this.maxTextScore,
      volumes: volumes ?? this.volumes,
      isAutoPlay: isAutoPlay ?? this.isAutoPlay,
      isRecord: isRecord ?? this.isRecord,
      isWarmUpCheck: isWarmUpCheck ?? this.isWarmUpCheck,
      isMiddleCheck: isMiddleCheck ?? this.isMiddleCheck,
      isFinalCheck: isFinalCheck ?? this.isFinalCheck,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      totalMilliseconds: totalMilliseconds ?? this.totalMilliseconds,
      prequestion: prequestion ?? this.prequestion,
    );
  }

  @override
  List<Object?> get props => [
        id,
        file,
        score,
        maxSliderScore,
        maxTextScore,
        volumes,
        isAutoPlay,
        isRecord,
        isWarmUpCheck,
        isMiddleCheck,
        isFinalCheck,
        startedAt,
        endedAt,
        totalMilliseconds,
        prequestion,
      ];

  Map<String, dynamic> toJson() => {
        'file': file,
        'score': score,
        'play_count': volumes.length,
        'volumes': volumes,
        'total_milliseconds': getTotalMilliseconds,
        'is_warmUp_check': isWarmUpCheck,
        'is_middle_check': isMiddleCheck,
        'is_final_check': isFinalCheck,
      };

  factory QuestionModel.fromJson(Map<String, dynamic> map) => _empty.copyWith(
        file: map['file'],
        score: double.tryParse(map['score'].toString()) ?? 0.0,
        volumes: [
          ...Iterable.castFrom(map['volumes'] ?? []).map((x) => double.tryParse(x.toString()) ?? 0.0),
        ],
        totalMilliseconds: int.tryParse(map['total_milliseconds'].toString()) ?? 0,
        isWarmUpCheck: map['is_warmUp_check'],
        isMiddleCheck: map['is_middle_check'],
        isFinalCheck: map['is_final_check'],
      );

  @override
  String toString() => 'id: $id file: $file score: $score isWarmUpCheck: $isWarmUpCheck isMiddleCheck: $isMiddleCheck isFinalCheck: $isFinalCheck';
}
