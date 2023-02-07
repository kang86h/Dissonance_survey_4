import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'text_choice.g.dart';

@JsonSerializable()
class TextChoice {
  final String text;
  String value;
  final TextEditingController? controller;

  TextChoice({
    required this.text,
    required this.value,
    this.controller,
  }) : super();

  factory TextChoice.fromJson(Map<String, dynamic> json) =>
      _$TextChoiceFromJson(json);
  Map<String, dynamic> toJson() => _$TextChoiceToJson(this);

  bool operator ==(o) => o is TextChoice && text == o.text && value == o.value;
  int get hashCode => text.hashCode ^ value.hashCode;
}
