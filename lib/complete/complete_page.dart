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
                    '아래로 내려서\n'
                    '"완료 창 까지 확인하였습니다" 체크후\n'
                    '"다음으로" 버튼을 눌러주세요\n'
                    '너무 일찍 설문을 마치신 경우\n'
                    '조금 기다리셔야 버튼이 나타납니다',
                    style: TextStyle(
                      fontSize: 20,
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
