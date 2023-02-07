enum QuestionType {
  none,
  hs4q2,
  hs4q3,
  hs4q4,
}

extension QuestionTypeEx on QuestionType {
  String get title =>
      {
        QuestionType.hs4q2: '2음화음(최대60점)',
        QuestionType.hs4q3: '3음화음(최대100점)',
        QuestionType.hs4q4: '4음화음(최대140점)',
      }[this] ??
      '';

  bool get isRandom => [QuestionType.hs4q2, QuestionType.hs4q3, QuestionType.hs4q4].contains(this);
}
