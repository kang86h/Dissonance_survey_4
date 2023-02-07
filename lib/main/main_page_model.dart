import 'package:dissonance_survey_4/main/model/question_model.dart';

import '../getx/get_model.dart';
import 'model/question_type.dart';

final DateTime defaultDateTime = DateTime(1970, 1, 1);

class MainPageModel extends GetModel {
  MainPageModel({
    required this.questions,
    required this.videoStartedAt,
    required this.videoEndedAt,
  });

  final Map<QuestionType, Iterable<QuestionModel>> questions;
  final DateTime videoStartedAt;
  final DateTime videoEndedAt;

  static final MainPageModel _empty = MainPageModel(
    questions: const {},
    videoStartedAt: defaultDateTime,
    videoEndedAt: defaultDateTime,
  );

  factory MainPageModel.empty() => _empty;

  @override
  bool get isEmpty => this == _empty;

  int get getVideoMilliseconds => videoEndedAt.difference(videoStartedAt).inMilliseconds;

  @override
  MainPageModel copyWith({
    Map<QuestionType, Iterable<QuestionModel>>? questions,
    DateTime? videoStartedAt,
    DateTime? videoEndedAt,
  }) {
    return MainPageModel(
      questions: questions ?? this.questions,
      videoStartedAt: videoStartedAt ?? this.videoStartedAt,
      videoEndedAt: videoEndedAt ?? this.videoEndedAt,
    );
  }

  Map<String, dynamic> toJson() => Map.fromEntries({
        ...questions.entries.where((x) => x.key != QuestionType.none).map((x) => MapEntry(x.key.name, x.value.map((y) => y.toJson()))),
      });

  @override
  List<Object?> get props => [questions, videoStartedAt, videoEndedAt];

  @override
  String toString() => 'questions: $questions videoStartedAt: $videoStartedAt videoEndedAt: $videoEndedAt';
}
