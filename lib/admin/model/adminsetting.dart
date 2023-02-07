import '../../getx/get_model.dart';

class AdminSetting extends GetModel {
  AdminSetting({
    required this.save_json,
  });

  final String save_json;

  static final AdminSetting _empty = AdminSetting(
    save_json: '',
  );

  factory AdminSetting.empty() => _empty;

  @override
  bool get isEmpty => this == _empty;

  @override
  AdminSetting copyWith({
    String? file,
  }) {
    return AdminSetting(
      save_json: save_json ?? this.save_json,
    );
  }

  @override
  List<Object?> get props => [
        save_json,
      ];

  @override
  String toString() => 'save_json: $save_json';
}
