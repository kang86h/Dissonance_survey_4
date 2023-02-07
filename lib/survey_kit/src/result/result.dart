import 'package:equatable/equatable.dart';

import '../../survey_kit.dart';

abstract class Result extends Equatable {
  final Identifier? id;
  final DateTime startDate;
  final DateTime endDate;

  Result({
    required this.id,
    required this.startDate,
    required this.endDate,
  });
}
