import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:skann_app/core/theme/app_text_styles.dart';

class CustomRichTextWidget extends StatelessWidget {
  const CustomRichTextWidget({
    super.key,
    required this.title,
    required this.secondTitle,
    this.onTap,
  });
  final String title;
  final String secondTitle;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: title,
        style: AppTextStyles.primaryTextW400S15,
        children: [
          TextSpan(
            text: secondTitle,
            style: AppTextStyles.primaryW400S15,
            recognizer: TapGestureRecognizer()..onTap = onTap,
          ),
        ],
      ),
    );
  }
}
