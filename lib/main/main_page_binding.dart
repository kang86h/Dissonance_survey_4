import 'package:get/get.dart';

import 'main_page_controller.dart';
import 'main_page_model.dart';
import 'model/question_model.dart';
import 'model/question_type.dart';

class MainPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MainPageController>(
      MainPageController(
        model: MainPageModel.empty().copyWith(
          questions: {
            QuestionType.none: [
              ...List.generate(3, (_) => QuestionModel.empty()),
              //볼륨조절 전 스텝 갯수
              QuestionModel.prequestion(),
              QuestionModel.volume(),
              QuestionModel.empty(),
            ],
            QuestionType.hs4q2: (QuestionType questionType) {
              final name = questionType.name.toUpperCase();
              final questions = List.generate(
                8,
                (i) => QuestionModel.empty().copyWith(
                  id: i + 1,
                  file: '$name/$name-${i + 1}.mp3',
                  maxSliderScore: 60,
                  maxTextScore: 1000,
                  isRecord: true,
                ),
              );
              if (questionType.isRandom) {
                questions.shuffle();
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
                  maxSliderScore: 100,
                  maxTextScore: 1000,
                  isRecord: true,
                ),
              );
              if (questionType.isRandom) {
                questions.shuffle();
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
                  maxSliderScore: 140,
                  maxTextScore: 1000,
                  isRecord: true,
                ),
              );
              if (questionType.isRandom) {
                questions.shuffle();
              }

              return questions;
            }(QuestionType.hs4q4),
          },
        ),
      ),
    );
  }
}
