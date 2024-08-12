import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../utils/colors.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    this.txt,
    required this.isUserMsg,
    this.image,
  });

  final String? txt;
  final bool isUserMsg;
  final Image? image;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isUserMsg ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            decoration: BoxDecoration(
                color: isUserMsg ? AppColors.grey : AppColors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(18)),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            margin: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                if (txt case final txt?) MarkdownBody(data: txt),
                if (image case final image?) image,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
