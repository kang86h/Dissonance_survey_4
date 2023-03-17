import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:cp949/cp949.dart';
import 'package:csv/csv.dart';
import 'package:download/download.dart';
import 'package:surveykit_example/admin/admin_page_model.dart';
import 'package:surveykit_example/admin/model/type/condition_model.dart';
import 'package:surveykit_example/admin/model/type/condition_type.dart';
import 'package:surveykit_example/admin/model/type/range_type.dart';
import 'package:surveykit_example/admin/model/type/result_field_type.dart';
import 'package:surveykit_example/admin/model/type/user_field_type.dart';
import 'package:surveykit_example/admin/model/type/value/user_gender_value.dart';
import 'package:surveykit_example/getx/extension.dart';
import 'package:surveykit_example/getx/get_controller.dart';
import 'package:surveykit_example/getx/get_rx_impl.dart';
import 'package:rxdart/rxdart.dart' as rx;
import 'package:surveykit_example/main/model/question_model.dart';

class AdminPageController extends GetController<AdminPageModel> {
  AdminPageController({
    required AdminPageModel model,
  }) : super(model);

  final rx.BehaviorSubject<List<QueryDocumentSnapshot<Map<String, dynamic>>>> userStream = rx.BehaviorSubject.seeded([])
    ..addStream(FirebaseFirestore.instance.collection('user').orderBy('createdAt', descending: true).snapshots().map((x) => x.docs));
  final rx.BehaviorSubject<List<QueryDocumentSnapshot<Map<String, dynamic>>>> resultStream = rx.BehaviorSubject.seeded([])
    ..addStream(FirebaseFirestore.instance.collection('result').orderBy('createdAt', descending: true).snapshots().take(1).map((x) => x.docs));

  late final RxList<QueryDocumentSnapshot<Map<String, dynamic>>> filterUserList = <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;
  late final RxList<QueryDocumentSnapshot<Map<String, dynamic>>> filterResultList = <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;

  @override
  void onInit() {
    super.onInit();
    userStream.listen((value) {
      onPressedApplyCondition();
    });
    resultStream.listen((value) {
      onPressedApplyCondition();
    });
  }

  @override
  void onClose() async {
    super.onClose();
    await Future.wait([
      userStream.close(),
      resultStream.close(),
    ]);
    filterUserList.close();
    filterResultList.close();
  }

  void onPressedAddCondition() {
    change(state.copyWith(
      conditions: [
        ...state.conditions,
        ConditionModel.empty(),
      ],
    ));
  }

  void onPressedApplyCondition() {
    final filterUserList = userStream.value.where((x) {
      final data = x.data();

      return state.conditions.every((x) {
        final first = x.value.firstOrNull;
        final second = x.value.secondOrNull;

        if (x.field == UserFieldType.age && first is int) {
          if (x.condition == ConditionType.more_than) {
            return data['age'] >= first;
          } else if (x.condition == ConditionType.less_than) {
            return data['age'] <= first;
          } else if (x.condition == ConditionType.between && second is int) {
            return data['age'] >= first && data['age'] <= second;
          } else if (x.condition == ConditionType.equals) {
            return data['age'] == first;
          } else if (x.condition == ConditionType.not_equals) {
            return data['age'] != first;
          } else {
            return true;
          }
        } else if (x.field == UserFieldType.gender && first is UserGenderValue) {
          if (x.condition == ConditionType.equals) {
            return data['gender'] == first.name;
          } else if (x.condition == ConditionType.not_equals) {
            return data['gender'] != first.name;
          } else {
            return true;
          }
        } else if (x.field == UserFieldType.video_milliseconds && first is int) {
          if (x.condition == ConditionType.more_than) {
            return data['video_milliseconds'] >= first;
          } else if (x.condition == ConditionType.less_than) {
            return data['video_milliseconds'] <= first;
          } else if (x.condition == ConditionType.between && second is int) {
            return data['video_milliseconds'] >= first && data['video_milliseconds'] <= second;
          } else if (x.condition == ConditionType.equals) {
            return data['video_milliseconds'] == first;
          } else if (x.condition == ConditionType.not_equals) {
            return data['video_milliseconds'] != first;
          } else {
            return true;
          }
        } else if (x.field == UserFieldType.createdAt && x.condition == ConditionType.between && first is DateTime && second is DateTime) {
          final timestamp = data['createdAt'];

          if (timestamp is Timestamp) {
            final dateTime = timestamp.toDate();

            return dateTime.millisecondsSinceEpoch >= first.millisecondsSinceEpoch &&
                dateTime.millisecondsSinceEpoch <= (second..add(Duration(days: 1))).millisecondsSinceEpoch;
          }
        }

        return true;
      });
    }).toList();
    final filterResultList = resultStream.value.where((x) {
      final data = x.data();

      final questions = data.entries.map((y) => y.value).whereType<Map<dynamic, dynamic>>().expand((y) {
        final map = Map.fromEntries([
          ...Map<String, dynamic>.from(y).entries.map((x) {
            return MapEntry(
              x.key,
              [
                ...Iterable.castFrom(x.value),
              ].map((y) => QuestionModel.fromJson(y)),
            );
          }),
        ]);

        return map.entries.expand((z) => z.value.map((w) => MapEntry(w.file, w)));
      });

      return state.conditions.every((x) {
        final first = x.value.firstOrNull;
        final second = x.value.secondOrNull;

        if (x.field == ResultFieldType.score && first is num) {
          final condition = ((num score) {
            if (x.condition == ConditionType.more_than) {
              return score >= first;
            } else if (x.condition == ConditionType.less_than) {
              return score <= first;
            } else if (x.condition == ConditionType.between && second is int) {
              return score >= first && score <= second;
            } else if (x.condition == ConditionType.equals) {
              return score == first;
            } else if (x.condition == ConditionType.not_equals) {
              return score != first;
            } else {
              return true;
            }
          });

          if (x.range == RangeType.any) {
            return questions.any((y) => condition(y.value.score));
          } else if (x.range == RangeType.all) {
            return questions.every((y) => condition(y.value.score));
          } else if (x.range == RangeType.max) {
            return condition(questions.map((x) => x.value.score).reduce(max));
          } else if (x.range == RangeType.min) {
            return condition(questions.map((x) => x.value.score).reduce(min));
          }
        } else if (x.field == ResultFieldType.volumes && first is num) {
          final condition = ((num volume) {
            if (x.condition == ConditionType.more_than) {
              return volume >= first;
            } else if (x.condition == ConditionType.less_than) {
              return volume <= first;
            } else if (x.condition == ConditionType.between && second is int) {
              return volume >= first && volume <= second;
            } else if (x.condition == ConditionType.equals) {
              return volume == first;
            } else if (x.condition == ConditionType.not_equals) {
              return volume != first;
            } else {
              return true;
            }
          });

          if (x.range == RangeType.any) {
            return questions.any((y) => y.value.volumes.any((z) => condition(z)));
          } else if (x.range == RangeType.all) {
            return questions.every((y) => y.value.volumes.every((z) => condition(z)));
          } else if (x.range == RangeType.max) {
            return condition(questions.expand((x) => x.value.volumes).reduce(max));
          } else if (x.range == RangeType.min) {
            return condition(questions.expand((x) => x.value.volumes).reduce(min));
          }
        } else if (x.field == ResultFieldType.play_count && first is int) {
          final condition = ((int playCount) {
            if (x.condition == ConditionType.more_than) {
              return playCount >= first;
            } else if (x.condition == ConditionType.less_than) {
              return playCount <= first;
            } else if (x.condition == ConditionType.between && second is int) {
              return playCount >= first && playCount <= second;
            } else if (x.condition == ConditionType.equals) {
              return playCount == first;
            } else if (x.condition == ConditionType.not_equals) {
              return playCount != first;
            } else {
              return true;
            }
          });

          if (x.range == RangeType.any) {
            return questions.any((y) => condition(y.value.volumes.length));
          } else if (x.range == RangeType.all) {
            return questions.every((y) => condition(y.value.volumes.length));
          } else if (x.range == RangeType.max) {
            return condition(questions.map((x) => x.value.volumes.length).reduce(max));
          } else if (x.range == RangeType.min) {
            return condition(questions.map((x) => x.value.volumes.length).reduce(min));
          }
        } else if (x.field == ResultFieldType.totalMilliseconds && first is int) {
          final condition = ((int totalMilliseconds) {
            if (x.condition == ConditionType.more_than) {
              return totalMilliseconds >= first;
            } else if (x.condition == ConditionType.less_than) {
              return totalMilliseconds <= first;
            } else if (x.condition == ConditionType.between && second is int) {
              return totalMilliseconds >= first && totalMilliseconds <= second;
            } else if (x.condition == ConditionType.equals) {
              return totalMilliseconds == first;
            } else if (x.condition == ConditionType.not_equals) {
              return totalMilliseconds != first;
            } else {
              return true;
            }
          });

          if (x.range == RangeType.any) {
            return questions.any((y) => condition(y.value.totalMilliseconds));
          } else if (x.range == RangeType.all) {
            return questions.every((y) => condition(y.value.totalMilliseconds));
          } else if (x.range == RangeType.max) {
            return condition(questions.map((x) => x.value.totalMilliseconds).reduce(max));
          } else if (x.range == RangeType.min) {
            return condition(questions.map((x) => x.value.totalMilliseconds).reduce(min));
          }
        }

        return true;
      });
    }).toList();

    final filterUserIdList = filterUserList.map((x) => x.id);
    final filterResultIdList = filterResultList.map((x) => x.data()['user_id']);

    this.filterUserList.value = filterUserList.where((x) => filterResultIdList.contains(x.id)).toList();
    this.filterResultList.value = filterResultList.where((x) => filterUserIdList.contains(x.data()['user_id'])).toList();
  }

  void onPressedUserDownload() {
    final rows = [
      [
        ...UserFieldType.values.map((x) => x.name),
      ],
      ...filterUserList.value.map((x) {
        final data = x.data();
        final sorted = [
          MapEntry('id', x.id),
          ...UserFieldType.values.where((x) => !data.keys.contains(x.name) && x.name != 'id').map((x) => MapEntry(x.name, '')),
          ...data.entries.where((x) => UserFieldType.values.map((y) => y.name).contains(x.key)),
        ].sorted((a, b) => getUserFieldIndex(name: a.key).compareTo(getUserFieldIndex(name: b.key)));

        return [
          ...sorted.map((y) {
            final value = y.value;

            if (value is Timestamp) {
              return value.toDate().toString();
            }
            if (y.key == 'prequestion') {
              return '(${value.toString().replaceAll(',', ' ')})';
            }

            return y.value.toString();
          }),
        ];
      }),
    ];
    final csv = ListToCsvConverter().convert(rows);
    final stream = Stream.fromIterable(encode(csv));
    download(stream, 'user_${DateTime.now().toIso8601String()}.csv');
  }

  void onPressedResultDownload() {
    final sorted = filterResultList.value.map((x) {
      final data = x.data();
      final sorted = data.entries.sorted((a, b) => getResultFieldIndex(name: a.key).compareTo(getResultFieldIndex(name: b.key)));
      return [
        data['user_id'],
        ...sorted.expand((y) {
          final value = y.value;

          if (value is Map<dynamic, dynamic>) {
            // 타입 변환
            final map = Map.fromEntries([
              ...Map<String, dynamic>.from(value).entries.map((x) {
                return MapEntry(
                  x.key,
                  [
                    ...Iterable.castFrom(x.value),
                  ].map((y) => QuestionModel.fromJson(y)),
                );
              }),
            ]);

            return map.entries.expand((z) => z.value.map((w) => MapEntry(w.file, w))).sorted((a, b) => a.value.file.compareTo(b.value.file));
          }

          return <MapEntry<String, QuestionModel>>[];
        }).toList(),
      ];
    }).toList();

    ResultFieldType.values.where((x) => x.isDropdown).forEach((tab) {
      final func = (QuestionModel question) {
        if (tab == ResultFieldType.score) {
          return question.score.toStringAsFixed(2);
        } else if (tab == ResultFieldType.volumes) {
          return question.volumes.map((x) => x.toStringAsFixed(2)).join(" ");
        } else if (tab == ResultFieldType.play_count) {
          return question.volumes.length;
        } else if (tab == ResultFieldType.totalMilliseconds) {
          return question.totalMilliseconds;
        }

        return '';
      };
      final rows = [
        [
          'user_id',
          ...sorted.take(1).expand((x) => x
              .whereType<MapEntry<String, QuestionModel>>()
              .where((x) => !x.value.isMiddleCheck && !x.value.isFinalCheck)
              .map((y) => y.value.header)),
          'hs4q2_check',
          'hs4q3_check',
          'hs4q4_check',
          'hs4q2_middle_check',
          'hs4q3_middle_check',
          'hs4q4_middle_check',
          'hs4q2_final_check',
          'hs4q3_final_check',
          'hs4q4_final_check',
        ],
        ...sorted.map((x) => [
              ...x.where((y) => y is String || (y is MapEntry<String, QuestionModel> && !y.value.isMiddleCheck && !y.value.isFinalCheck)).map((y) {
                if (y is String) {
                  return y;
                } else if (y is MapEntry<String, QuestionModel>) {
                  return func(y.value);
                }

                return '';
              }),
              ...x.whereType<MapEntry<String, QuestionModel>>().where((y) => y.value.isMiddleCheck).map((y) => y.value).map((x) => x.header),
              ...x.whereType<MapEntry<String, QuestionModel>>().where((y) => y.value.isMiddleCheck).map((y) => y.value).map(func),
              ...x.whereType<MapEntry<String, QuestionModel>>().where((y) => y.value.isFinalCheck).map((y) => y.value).map(func),
            ]),
      ];
      final csv = ListToCsvConverter().convert(rows);
      final stream = Stream.fromIterable(encode(csv));
      download(stream, '${tab.name}_${DateTime.now().toIso8601String()}.csv');
    });

    final rows = [
      [
        'user_id',
        'q2ReliabilityCount',
        'q2ReliabilityLength',
        'q3ReliabilityCount',
        'q3ReliabilityLength',
        'q4ReliabilityCount',
        'q4ReliabilityLength',
        'totalReliabilityCount',
        'totalReliabilityLength',
        'q2ConsistencyPlus',
        'q2ConsistencyMinus',
        'q3ConsistencyPlus',
        'q3ConsistencyMinus',
        'q4ConsistencyPlus',
        'q4ConsistencyMinus',
        'totalConsistencyCount',
        'totalConsistencyLength',
      ],
      ...filterResultList.value.map((x) {
        final data = x.data();

        return [
          data['user_id'],
          data['q2ReliabilityCount'],
          data['q2ReliabilityLength'],
          data['q3ReliabilityCount'],
          data['q3ReliabilityLength'],
          data['q4ReliabilityCount'],
          data['q4ReliabilityLength'],
          data['totalReliabilityCount'],
          data['totalReliabilityLength'],
          data['q2ConsistencyPlus'],
          data['q2ConsistencyMinus'],
          data['q3ConsistencyPlus'],
          data['q3ConsistencyMinus'],
          data['q4ConsistencyPlus'],
          data['q4ConsistencyMinus'],
          data['totalConsistencyCount'],
          data['totalConsistencyLength'],
        ];
      }),
    ];
    final csv = ListToCsvConverter().convert(rows);
    final stream = Stream.fromIterable(encode(csv));
    download(stream, 'suitability_${DateTime.now().toIso8601String()}.csv');
  }

  void onPressedRemoveCondition(int index) {
    change(state.copyWith(
      conditions: [
        ...state.conditions.toList().asMap().entries.where((x) => x.key != index).map((x) => x.value),
      ],
    ));
  }

  void onPressedCondition(int index, ConditionModel condition) {
    change(state.copyWith(
      conditions: [
        ...state.conditions.toList().asMap().entries.map((x) => x.key == index ? condition : x.value),
      ],
    ));
  }
}
