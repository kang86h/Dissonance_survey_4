import 'package:surveykit_example/admin/model/type/user_field_type.dart';

enum ConditionType {
  empty,
  more_than,
  less_than,
  between,
  equals,
  not_equals,
}

extension ConditionTypeEx on ConditionType {
  bool isField(dynamic fieldType) {
    if (fieldType == UserFieldType.gender) {
      return [ConditionType.empty, ConditionType.equals, ConditionType.not_equals].contains(this);
    } else if (fieldType == UserFieldType.createdAt) {
      return [ConditionType.between].contains(this);
    }

    return true;
  }
}

/*
이상 - more than
이하 - less than
사이 - between
동등 - equals
다를 때 - not equals
*/
