// import 'package:flutter/material.dart';
// import 'package:ybs_pay/View/widgets/spacing.dart';
//
//
//
// /// A custom widget that displays a horizontal divider with text in the center.
// class TextDivider extends StatelessWidget {
//   /// Creates a `TextDivider` widget.
//   ///
//   /// The [text] parameter is required and represents the text to be displayed in the center of the divider.
//   const TextDivider({super.key, required this.text});
//
//   /// The text to be displayed in the center of the divider.
//   final String text;
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(child: Divider(color: Colors.grey.shade300)),
//         spacing(width: 25),
//         Text(
//           text,
//           textAlign: TextAlign.center,
//           style: StyleHelper.titleSmall(context),
//         ),
//         spacing(width: 25),
//         Expanded(child: Divider(color: Colors.grey.shade300)),
//       ],
//     );
//   }
// }
