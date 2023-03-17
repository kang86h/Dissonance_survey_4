import 'dart:math';

import 'package:get/get.dart';
import 'package:surveykit_example/main/main_page.dart';

import 'main_page_controller.dart';
import 'main_page_model.dart';
import 'model/question_model.dart';
import 'model/question_type.dart';

class MainPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MainPageController>((() {
      final questions = {
        QuestionType.none: [
          ...List.generate(5, (_) => QuestionModel.empty()),
          //볼륨조절 전 스텝 갯수
          QuestionModel.prequestion(),
          QuestionModel.volume(),
          ...List.generate(4, (_) => QuestionModel.empty()),
        ],
        QuestionType.hs4q2: (QuestionType questionType) {
          final name = questionType.name.toUpperCase();
          final questions = List.generate(
            8,
            (i) => QuestionModel.empty().copyWith(
              id: i + 1,
              file: '$name/$name-${i + 1}.mp3',
              score: 56 / 2,
              maxSliderScore: 56,
              maxTextScore: 1000,
              isRecord: true,
              isWarmUpCheck: MainPage.q2WarmUpCheckId.contains(i + 1),
            ),
          );
          if (questionType.isRandom) {
            questions.shuffle();
          }

          final index = Random().nextInt(3);
          final question = questions[Random().nextInt(3)].copyWith(
            isMiddleCheck: true,
          );

          if (index == 0) {
            questions.add(question);
          } else {
            questions.insert(questions.length - index, question);
          }

          return questions;
        }(QuestionType.hs4q2),
        QuestionType.hs4q3: (QuestionType questionType) {
          final name = questionType.name.toUpperCase();
          final questions = List.generate(
            6,
            (i) => QuestionModel.empty().copyWith(
              id: i + 1,
              file: '$name/$name-${i + 1}.mp3',
              score: 97 / 2,
              maxSliderScore: 97,
              maxTextScore: 1000,
              isRecord: true,
              isWarmUpCheck: MainPage.q3WarmUpCheckId.contains(i + 1),
            ),
          );
          if (questionType.isRandom) {
            questions.shuffle();
          }

          final index = Random().nextInt(3);
          final question = questions[Random().nextInt(3)].copyWith(
            isMiddleCheck: true,
          );

          if (index == 0) {
            questions.add(question);
          } else {
            questions.insert(questions.length - index, question);
          }

          return questions;
        }(QuestionType.hs4q3),
        QuestionType.hs4q4: (QuestionType questionType) {
          final name = questionType.name.toUpperCase();
          final questions = List.generate(
            6,
            (i) => QuestionModel.empty().copyWith(
              id: i + 1,
              file: '$name/$name-${i + 1}.mp3',
              score: 137 / 2,
              maxSliderScore: 137,
              maxTextScore: 1000,
              isRecord: true,
              isWarmUpCheck: MainPage.q4WarmUpCheckId.contains(i + 1),
            ),
          );
          if (questionType.isRandom) {
            questions.shuffle();
          }

          final index = Random().nextInt(3);
          final question = questions[Random().nextInt(3)].copyWith(
            isMiddleCheck: true,
          );

          if (index == 0) {
            questions.add(question);
          } else {
            questions.insert(questions.length - index, question);
          }

          return questions;
        }(QuestionType.hs4q4),
      };

      return MainPageController(
        model: MainPageModel.empty().copyWith(
          questions: {
            ...questions,
            QuestionType.check: [
              ...questions.values
                  .expand((x) => x)
                  .where((x) => x.isMiddleCheck)
                  .map((x) => x.copyWith(
                        isMiddleCheck: false,
                        isFinalCheck: true,
                      )),
            ],
            QuestionType.complete: [
              ...List.generate(2, (_) => QuestionModel.empty()),
            ]
          },
        ),
      );
    })());
  }
}
