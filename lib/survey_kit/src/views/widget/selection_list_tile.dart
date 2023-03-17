import 'package:flutter/material.dart';
import 'package:surveykit_example/survey_kit/src/views/decoration/input_decoration.dart';

class SelectionListTile extends StatelessWidget {
  final String text;
  final Function onTap;
  final bool isSelected;
  final TextEditingController? controller;
  final Widget child;
  final Widget icon;

  const SelectionListTile({
    Key? key,
    required this.text,
    required this.onTap,
    this.isSelected = false,
    this.controller,
    this.child = const SizedBox.shrink(),
    this.icon = const Icon(Icons.check),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline5?.copyWith(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).textTheme.headline5?.color,
                      ),
                ),
                child,
                Stack(
                  children: [
                    Icon(
                      Icons.check_box_outline_blank,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).textTheme.headline5?.color,
                      size: 40,
                    ),
                    Icon(
                      Icons.check_box_outlined,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      size: 40,
                    ),
                  ],
                ),
              ],
            ),
            onTap: () => onTap.call(),
          ),
        ),
        if (controller is TextEditingController && isSelected) ...[
          const SizedBox(height: 10),
          TextField(
            decoration: textFieldInputDecoration(),
            enabled: isSelected,
            controller: controller,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 10),
        ],
        Divider(
          color: Colors.cyan,
        ),
      ],
    );
  }
}
