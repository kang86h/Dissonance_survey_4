import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'get_rx_impl.dart' as getx;

extension BoolOptionalEx on bool? {
  bool get elvis => this ?? false;
}

extension BrightnessOptionalEx on Brightness? {
  Brightness get elvis => this ?? Brightness.light;
}

extension ColorOptionalEx on Color? {
  Color get elvis => this ?? Colors.transparent;
}

extension DoubleOptionalEx on double? {
  double get elvis => this ?? 0.0;
}

extension DurationOptionalEx on Duration? {
  Duration get elvis => this ?? Duration.zero;
}

extension IntOptionalEx on int? {
  int get elvis => this ?? 0;

  int plus(int other) => this.elvis + other;
}

extension IterableOptionalEx<T> on Iterable<T>? {
  Iterable<T> get elvis => this ?? const [];

  T? operator [](int? i) => (i?.isNotNegative).elvis && elvis.length > i.elvis ? elvis.elementAt(i.elvis) : null;

  T? get firstOrNull => isset ? elvis.first : null;

  T? get secondOrNull {
    final iterator = elvis.iterator;
    return Iterable.generate(2).any((_) => !iterator.moveNext()) ? null : iterator.current;
  }

  T? get lastOrNull => isset ? elvis.last : null;

  T? get lastSecondOrNull => isset && elvis.length > 1 ? elvis[elvis.length - 2] : null;

  int get lastIndex => isset ? elvis.length - 1 : 0;

  bool get isNullOrEmpty => this == null || (this?.isEmpty).elvis;

  bool get isset => !isNullOrEmpty;
}

extension NumNullableEx on num? {
  num get elvis => this ?? 0;
}

extension NumEx on num {
  bool get isPositive => this > 0;

  bool get isNotNegative => !isNegative;
}

extension RxNullableEx<T> on Rx<T>? {
  Widget rx(Widget Function(Rx<T> rx) builder, {Widget? onEmpty}) {
    return this is Rx<T> ? ObxValue<Rx<T>>(builder, this!) : onEmpty ?? const SizedBox.shrink();
  }
}

extension GetXRxNullableEx<T> on getx.Rx<T>? {
  Widget rx(Widget Function(getx.Rx<T> rx) builder, {Widget? onEmpty}) {
    return this is getx.Rx<T> ? ObxValue<getx.Rx<T>>(builder, this!) : onEmpty ?? const SizedBox.shrink();
  }
}

extension RxListNullableEx<T> on RxList<T>? {
  Widget rx(Widget Function(RxList<T> rx) builder, {Widget? onEmpty}) {
    return this is RxList<T> ? ObxValue<RxList<T>>(builder, this!) : onEmpty ?? const SizedBox.shrink();
  }
}

extension GetXRxListNullableEx<T> on getx.RxList<T>? {
  Widget rx(Widget Function(getx.RxList<T> rx) builder, {Widget? onEmpty}) {
    return this is getx.RxList<T> ? ObxValue<getx.RxList<T>>(builder, this!) : onEmpty ?? const SizedBox.shrink();
  }
}

extension StreamOptionalEx<T> on Stream<T>? {
  Stream<T> get elvis => this ?? const Stream.empty();
}

extension StringOptionalEx on String? {
  String get elvis => this ?? '';

  bool get isNullOrEmpty => this == null || (this?.isEmpty).elvis;

  bool get isset => !isNullOrEmpty;
}

extension ThemeDataOptionalEx on ThemeData? {
  ThemeData get elvis => this ?? ThemeData.fallback();
}

extension ValueNullableEx<T> on Value<T>? {
  Widget rx(
    NotifierBuilder<T> widget, {
    Widget Function(String? error)? onError,
    Widget? onLoading,
    Widget? onEmpty,
  }) {
    return this?.rx(widget, onError: onError, onLoading: onLoading, onEmpty: onEmpty) ?? const SizedBox.shrink();
  }
}

extension ValueEx<T> on Value<T> {
  Widget rx(
    NotifierBuilder<T> widget, {
    Widget Function(String? error)? onError,
    Widget? onLoading,
    Widget? onEmpty,
  }) {
    return SimpleBuilder(builder: (_) {
      if (status.isLoading) {
        return onLoading ?? const CircularProgressIndicator();
      } else if (status.isError) {
        return onError is Widget Function(String?) ? onError(status.errorMessage) : const SizedBox.shrink();
      } else if (status.isEmpty) {
        return onEmpty ?? const SizedBox.shrink();
      }
      return widget(value!);
    });
  }
}

extension WidgetOptionalEx on Widget? {
  Widget get elvis => this ?? const SizedBox();
}

extension WidgetBuilderOptionalEx on WidgetBuilder? {
  Widget elvis(BuildContext context) => this?.call(context) ?? const SizedBox();
}
