import 'package:flutter/material.dart';
import 'package:gemini_ai_chat_bot/core/utils/text.dart';

class ShowErrorMessage extends StatelessWidget {
  const ShowErrorMessage({
    super.key,
    required this.msg,
  });

  final String msg;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        msg,
        style: title1Bold,
      ),
      content: SingleChildScrollView(
        child: SelectableText(msg),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Ok',
              style: title2Bold,
            ))
      ],
    );
  }
}
