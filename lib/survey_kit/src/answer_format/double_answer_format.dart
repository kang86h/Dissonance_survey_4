// by Antonio Bruno, Giacomo Ignesti and Massimo Martinelli

import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:surveykit_example/getx/get_rx_impl.dart';

import '../../survey_kit.dart';

part 'double_answer_format.g.dart';

@JsonSerializable()
class DoubleAnswerFormat implements AnswerFormat {
  final double? defaultValue;
  final String hint;
  final TextEditingController? controller;
  final Rx<Color>? color;
  final RxBool? isCheck;

  const DoubleAnswerFormat({
    this.defaultValue,
    this.hint = '',
    this.controller,
    this.color,
    this.isCheck,
  }) : super();

  factory DoubleAnswerFormat.fromJson(Map<String, dynamic> json) => _$DoubleAnswerFormatFromJson(json);

  Map<String, dynamic> toJson() => _$DoubleAnswerFormatToJson(this);
}
