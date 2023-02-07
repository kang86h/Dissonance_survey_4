import 'package:equatable/equatable.dart';

abstract class GetModel extends Equatable {
  bool get isEmpty;

  GetModel copyWith();
}
