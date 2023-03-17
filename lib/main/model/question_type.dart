enum QuestionType {
  none,
  hs4q2,
  hs4q3,
  hs4q4,
  check,
  complete,
}

extension QuestionTypeEx on QuestionType {
  String get title =>
      {
        QuestionType.hs4q2: '2음화음(최대56점)',
        QuestionType.hs4q3: '3음화음(최대97점)',
        QuestionType.hs4q4: '4음화음(최대137점)',
      }[this] ??
      '';

  bool get isRandom => [QuestionType.hs4q2, QuestionType.hs4q3, QuestionType.hs4q4].contains(this);

  bool get isLength => isRandom || [QuestionType.check].contains(this);
}
