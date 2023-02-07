enum ResultFieldType {
  user_id,
  question,
  score,
  volumes,
  play_count,
  totalMilliseconds,
}

extension ResultFieldTypeEx on ResultFieldType {
  bool get isDropdown => [
        ResultFieldType.score,
        ResultFieldType.volumes,
        ResultFieldType.play_count,
        ResultFieldType.totalMilliseconds,
      ].contains(this);
}

List<String> getResultFieldList() => ResultFieldType.values.map((x) => x.name).toList();

int getResultFieldIndex({required String name}) => getResultFieldList().indexOf(name);

/*

enum ResultFieldType {
  score,
  volumes,
  play_count,
  totalMilliseconds,
}

extension ResultFieldTypeEx on ResultFieldType {
  bool get isDropdown => [
        ResultFieldType.score,
        ResultFieldType.volumes,
        ResultFieldType.play_count,
        ResultFieldType.totalMilliseconds,
      ].contains(this);
}

List<String> getResultFieldList() => ResultFieldType.values.map((x) => x.name).toList();

int getResultFieldIndex({required String name}) => getResultFieldList().indexOf(name);

*/
