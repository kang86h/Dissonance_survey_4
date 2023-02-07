import '../../survey_kit.dart';

abstract class AnswerFormat {
  const AnswerFormat();

  factory AnswerFormat.fromJson(Map<String, dynamic> json) {
    switch (json['type'] as String) {
      case 'bool':
        return BooleanAnswerFormat.fromJson(json);
      case 'integer':
        return IntegerAnswerFormat.fromJson(json);
      case 'double':
        return DoubleAnswerFormat.fromJson(json);
      case 'text':
        return TextAnswerFormat.fromJson(json);
      case 'date':
        return DateAnswerFormat.fromJson(json);
      case 'single':
        return SingleChoiceAnswerFormat.fromJson(json);
      case 'multiple':
        return MultipleChoiceAnswerFormat.fromJson(json);
      case 'multiple_double':
        return MultipleDoubleAnswerFormat.fromJson(json);
      case 'scale':
        return ScaleAnswerFormat.fromJson(json);
      case 'time':
        return TimeAnswerFormat.fromJson(json);
      case 'file':
        return ImageAnswerFormat.fromJson(json);
      default:
        throw AnswerFormatNotDefinedException();
    }
  }

  Map<String, dynamic> toJson();
}
