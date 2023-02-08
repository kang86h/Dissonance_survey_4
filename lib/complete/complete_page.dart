import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CompletePage extends StatelessWidget {
  const CompletePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(width: 500),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                    color: Colors.cyan,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    '설문에 참여해주셔서 감사합니다\n'
                    '아래로 내려서 "다음으로" 버튼을\n'
                    '눌러주세요',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}