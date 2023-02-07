enum UserFieldType {
  id,
  age,
  gender,
  prequestion,
  video_milliseconds,
  createdAt,
}

extension UserFieldTypeEx on UserFieldType {
  bool get isDropdown => [
        UserFieldType.age,
        UserFieldType.gender,
        UserFieldType.video_milliseconds,
        UserFieldType.createdAt,
      ].contains(this);
}

List<String> getUserFieldList() => UserFieldType.values.map((x) => x.name).toList();

int getUserFieldIndex({required String name}) => getUserFieldList().indexOf(name);
