import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:dissonance_survey_4/admin/admin_page_controller.dart';
import 'package:dissonance_survey_4/admin/model/type/condition_type.dart';
import 'package:dissonance_survey_4/admin/model/type/range_type.dart';
import 'package:dissonance_survey_4/admin/model/type/result_field_type.dart';
import 'package:dissonance_survey_4/admin/model/type/user_field_type.dart';
import 'package:dissonance_survey_4/admin/model/type/value/user_gender_value.dart';
import 'package:dissonance_survey_4/getx/extension.dart';
import 'package:dissonance_survey_4/main/model/question_model.dart';
import '../getx/get_rx_impl.dart';

class AdminPage extends GetView<AdminPageController> {
  const AdminPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: ResultFieldType.values.where((x) => x.isDropdown).length,
          child: controller.rx((state) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...state.conditions.toList().asMap().entries.expand((x) => [
                    if (x.key > 0) ...[
                      const SizedBox(height: 10),
                      Divider(
                        height: 1,
                        indent: 20,
                        endIndent: 20,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 10),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton(
                            onChanged: (field) => controller.onPressedCondition(
                                x.key,
                                x.value.copyWith(
                                  field: field,
                                  range: RangeType.empty,
                                  condition: field == UserFieldType.createdAt ? ConditionType.between : ConditionType.empty,
                                  value: (() {
                                    if (field == UserFieldType.createdAt) {
                                      final now = DateTime.now();
                                      return [
                                        DateTime(now.year, now.month, now.day, 0, 0, 0),
                                        DateTime(now.year, now.month, now.day, 23, 59, 59),
                                      ];
                                    }

                                    return const [];
                                  })(),
                                )),
                            isExpanded: true,
                            value: x.value.field,
                            items: [
                              ...UserFieldType.values.where((y) => y.isDropdown).map((y) => DropdownMenuItem(
                                value: y,
                                child: Text(y.name),
                              )),
                              ...ResultFieldType.values.where((y) => y.isDropdown).map((y) => DropdownMenuItem(
                                value: y,
                                child: Text(y.name),
                              )),
                            ],
                          ),
                        ),
                        Expanded(
                          child: DropdownButton<RangeType>(
                            onChanged: x.value.field is ResultFieldType
                                ? (range) => controller.onPressedCondition(
                                x.key,
                                x.value.copyWith(
                                  range: range,
                                  condition: ConditionType.empty,
                                  value: const [],
                                ))
                                : null,
                            isExpanded: true,
                            value: x.value.range,
                            items: [
                              ...RangeType.values.map((y) => DropdownMenuItem(
                                value: y,
                                child: y == RangeType.empty ? const SizedBox.shrink() : Text(y.name),
                              )),
                            ],
                          ),
                        ),
                        Expanded(
                          child: DropdownButton<ConditionType>(
                            onChanged: (condition) => controller.onPressedCondition(
                                x.key,
                                x.value.copyWith(
                                  condition: condition,
                                  value: const [],
                                )),
                            isExpanded: true,
                            value: x.value.condition,
                            items: [
                              ...ConditionType.values.where((y) => y.isField(x.value.field)).map((y) => DropdownMenuItem(
                                value: y,
                                child: y == ConditionType.empty ? const SizedBox.shrink() : Text(y.name),
                              )),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: (() {
                            final field = x.value.field;

                            if (field == UserFieldType.gender) {
                              return DropdownButton<UserGenderValue>(
                                onChanged: (value) => controller.onPressedCondition(
                                    x.key,
                                    x.value.copyWith(
                                      value: [value],
                                    )),
                                isExpanded: true,
                                value: x.value.value.firstOrNull,
                                items: [
                                  ...UserGenderValue.values.map((y) => DropdownMenuItem(
                                    value: y,
                                    child: Text(y.name),
                                  )),
                                ],
                              );
                            } else if (field == UserFieldType.createdAt && x.value.condition == ConditionType.between) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: CalendarDatePicker(
                                      onDateChanged: (value) => controller.onPressedCondition(
                                          x.key,
                                          x.value.copyWith(
                                            value: [value, x.value.value.secondOrNull],
                                          )),
                                      firstDate: DateTime(2000, 1, 1),
                                      lastDate: DateTime(2099, 12, 31),
                                      initialDate: DateTime.now(),
                                    ),
                                  ),
                                  Expanded(
                                    child: CalendarDatePicker(
                                      onDateChanged: (value) => controller.onPressedCondition(
                                          x.key,
                                          x.value.copyWith(
                                            value: [x.value.value.firstOrNull, value],
                                          )),
                                      firstDate: DateTime(2000, 1, 1),
                                      lastDate: DateTime(2099, 12, 31),
                                      initialDate: DateTime.now(),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              if (x.value.condition == ConditionType.between) {
                                return Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        onChanged: (value) => controller.onPressedCondition(
                                            x.key,
                                            x.value.copyWith(
                                              value: [int.tryParse(value).elvis, x.value.value.secondOrNull],
                                            )),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        onChanged: (value) => controller.onPressedCondition(
                                            x.key,
                                            x.value.copyWith(
                                              value: [x.value.value.firstOrNull, int.tryParse(value).elvis],
                                            )),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                  ],
                                );
                              }

                              return TextField(
                                onChanged: (value) => controller.onPressedCondition(
                                    x.key,
                                    x.value.copyWith(
                                      value: [int.tryParse(value).elvis],
                                    )),
                                keyboardType: TextInputType.number,
                              );
                            }
                          })(),
                        ),
                        IconButton(
                          onPressed: () => controller.onPressedRemoveCondition(x.key),
                          icon: Icon(
                            Icons.close,
                          ),
                        ),
                      ],
                    ),
                  ]),
                  IconButton(
                    onPressed: controller.onPressedAddCondition,
                    icon: Icon(
                      Icons.add,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: controller.onPressedApplyCondition,
                        icon: Icon(
                          Icons.check,
                        ),
                      ),
                      IconButton(
                        onPressed: controller.onPressedUserDownload,
                        icon: Icon(
                          Icons.download,
                        ),
                      ),
                      IconButton(
                        onPressed: controller.onPressedResultDownload,
                        icon: Icon(
                          Icons.download_outlined,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 300,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: Colors.cyan,
                            ),
                          ),
                          child: controller.filterUserList.rx((rx) {
                            if (rx.value.isNullOrEmpty) {
                              return const Padding(
                                padding: const EdgeInsets.all(20),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            return Table(
                              children: [
                                TableRow(
                                  children: [
                                    ...UserFieldType.values.map((x) => TableCell(
                                      child: Text(x.name),
                                    )),
                                  ],
                                ),
                                ...rx.value.map((x) {
                                  final data = x.data();
                                  final sorted = [
                                    MapEntry('id', x.id),
                                    ...UserFieldType.values
                                        .where((x) => !data.keys.contains(x.name) && x.name != 'id')
                                        .map((x) => MapEntry(x.name, '')),
                                    ...data.entries.where((x) => UserFieldType.values.map((y) => y.name).contains(x.key)),
                                  ].sorted((a, b) => getUserFieldIndex(name: a.key).compareTo(getUserFieldIndex(name: b.key)));

                                  return TableRow(
                                    children: [
                                      ...sorted.map((y) {
                                        final value = y.value;

                                        if (value is Timestamp) {
                                          return TableCell(
                                            child: Text(value.toDate().toString()),
                                          );
                                        }

                                        return TableCell(
                                          child: Text(y.value.toString()),
                                        );
                                      }),
                                    ],
                                  );
                                })
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                  TabBar(
                    tabs: [
                      ...ResultFieldType.values.where((x) => x.isDropdown).map((x) => Tab(
                        child: Text(
                          x.name,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 300,
                    child: TabBarView(
                      children: [
                        ...ResultFieldType.values.where((x) => x.isDropdown).map(
                              (tab) => SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 2,
                                    color: Colors.cyan,
                                  ),
                                ),
                                child: controller.filterResultList.rx((rx) {
                                  return Table(
                                    children: [
                                      ...rx.value.asMap().entries.expand((x) {
                                        final data = x.value.data();
                                        final sorted = (() {
                                          final sorted = data.entries
                                              .sorted((a, b) => getResultFieldIndex(name: a.key).compareTo(getResultFieldIndex(name: b.key)));
                                          return sorted.expand((y) {
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

                                              return [
                                                // value 안의 questionModel 하나씩 file을 key로 하여 풂
                                                ...map.entries
                                                    .expand((z) => z.value.map((w) => MapEntry(w.file, w)))
                                                    .sorted((a, b) => a.value.file.compareTo(b.value.file)),
                                              ];
                                            } else if (ResultFieldType.values.map((z) => z.name).contains(y.key)) {
                                              // user_id인 경우
                                              return [y];
                                            }

                                            // createdAt인 경우
                                            return [];
                                          });
                                        })();
                                        final header = TableRow(
                                          children: [
                                            TableCell(
                                              child: Text('user_id'),
                                            ),
                                            ...sorted.map((y) {
                                              final value = y.value;

                                              if (value is QuestionModel) {
                                                return TableCell(
                                                  child: Text(value.header),
                                                );
                                              }

                                              return TableCell(
                                                child: const SizedBox.shrink(),
                                              );
                                            }),
                                          ],
                                        );
                                        final tableRow = TableRow(
                                          children: [
                                            TableCell(
                                              child: Text(data['user_id']),
                                            ),
                                            ...sorted.map((y) {
                                              final value = y.value;

                                              if (value is QuestionModel) {
                                                if (tab == ResultFieldType.score) {
                                                  return TableCell(
                                                    child: Text('${value.score.toStringAsFixed(2)}'),
                                                  );
                                                } else if (tab == ResultFieldType.volumes) {
                                                  return TableCell(
                                                    child: Text('${value.volumes.map((x) => x.toStringAsFixed(2))}'),
                                                  );
                                                } else if (tab == ResultFieldType.play_count) {
                                                  return TableCell(
                                                    child: Text('${value.volumes.length}'),
                                                  );
                                                } else if (tab == ResultFieldType.totalMilliseconds) {
                                                  return TableCell(
                                                    child: Text('${value.totalMilliseconds}'),
                                                  );
                                                }
                                              }

                                              return TableCell(
                                                child: const SizedBox.shrink(),
                                              );
                                            }),
                                          ],
                                        );

                                        return [
                                          if (x.key == 0) header,
                                          tableRow,
                                        ];
                                      }),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
