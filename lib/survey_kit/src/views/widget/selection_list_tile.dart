import 'package:flutter/material.dart';
import 'package:dissonance_survey_4/survey_kit/src/views/decoration/input_decoration.dart';

class SelectionListTile extends StatelessWidget {
  final String text;
  final Function onTap;
  final bool isSelected;
  final TextEditingController? controller;

  const SelectionListTile({
    Key? key,
    required this.text,
    required this.onTap,
    this.isSelected = false,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: ListTile(
            contentPadding: EdgeInsets.only(left: 40),
            title: Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline5?.copyWith(
                    color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.headline5?.color,
                  ),
            ),
            trailing: isSelected
                ? Icon(
                    Icons.check,
                    size: 32,
                    color: isSelected ? Theme.of(context).primaryColor : Colors.black,
                  )
                : Container(
                    width: 32,
                    height: 32,
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
