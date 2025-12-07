// import 'package:flutter/material.dart';
//
//
// import '../../core/utils/global_methods.dart';
// import '../../core/utils/navigator.dart';
// import '../../core/utils/styles.dart';
// import 'custom_button.dart';
//
// /// Widget for the header of a dialog.
// class DialogHeader extends StatelessWidget {
//   /// Constructs a [DialogHeader] with the provided [title].
//   const DialogHeader({super.key, required this.title});
//
//   /// The title to display in the dialog.
//   final String title;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
//       child: Row(
//         children: [
//           Expanded(
//             child: Text(
//               title,
//               maxLines: 1,
//               style: StyleHelper.titleLarge(context)?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           CustomButton(
//             title: trans(context, key: 'close'),
//             color: ColorHelper.grey20Lite(context),
//             textColor: ColorHelper.titleMediumColor(context),
//             onTap: () {
//               navigateBack(context);
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
