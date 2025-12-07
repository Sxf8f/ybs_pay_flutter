// import 'package:flutter/material.dart';
//
// import 'action_icon_button.dart';
//
// /// A widget that displays a back button.
// ///
// /// The [BackButtonWidget] class is a stateless widget that represents a back button
// /// in the form of a row containing an [ActionIconButton] with an arrow back icon.
// /// The [onTap] callback is triggered when the button is pressed.
// class BackButtonWidget extends StatelessWidget {
//   /// Creates a [BackButtonWidget].
//   ///
//   /// The [onTap] parameter is a required callback function that is triggered when
//   /// the back button is pressed.
//   const BackButtonWidget({super.key, required this.onTap});
//
//   /// The callback function triggered when the back button is pressed.
//   final Function() onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         ActionIconButton(
//           icon: Icons.arrow_back,
//           onPressed: onTap,
//         ),
//       ],
//     );
//   }
// }
