// import 'package:flutter/material.dart';
//
//
//
// /// A custom widget that represents an action icon button.
// ///
// /// This widget combines an [IconButton] with an optional badge to display additional information.
// /// It is typically used in app bars, toolbars, or any other UI element that requires an action button.
// ///
// /// The [ActionIconButton] requires an [icon] to display, and an [onPressed] callback function
// /// that gets invoked when the button is pressed.
// ///
// /// Additional customizations can be made using the following properties:
// ///   - [size]: The size of the icon. Default is 22.
// ///   - [iconColor]: The color of the icon. Default is [AppColors.grey100].
// ///   - [backgroundColor]: The background color of the button. Default is [AppColors.grey20].
// ///   - [showBadge]: Determines whether to show a badge or not. Default is false.
// ///   - [badgeLabel]: The label text to display on the badge. Default is null.
// ///   - [badgeOffset]: The offset position of the badge. Default is [Offset(-5, 0.2)].
// ///
// class ActionIconButton extends StatelessWidget {
//   const ActionIconButton(
//       {super.key,
//       required this.icon,
//       this.size = 22,
//       this.iconColor,
//       this.backgroundColor,
//       required this.onPressed,
//       this.showBadge = false,
//       this.badgeLabel,
//       this.badgeOffset = const Offset(-5, 0.2)});
//
//   /// The icon to display on the button.
//   final IconData icon;
//
//   /// The color of the icon.
//   final Color? iconColor;
//
//   /// The size of the icon.
//   final double size;
//
//   /// The background color of the button.
//   final Color? backgroundColor;
//
//   /// The callback function to invoke when the button is pressed.
//   final VoidCallback onPressed;
//
//   /// Determines whether to show a badge or not.
//   final bool showBadge;
//
//   /// The label text to display on the badge.
//   final String? badgeLabel;
//
//   /// The offset position of the badge.
//   final Offset badgeOffset;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//           color: backgroundColor ?? ColorHelper.grey20Lite(context),
//           shape: BoxShape.circle),
//       child: Badge(
//         label: Text(badgeLabel ?? ''),
//         offset: badgeOffset,
//         isLabelVisible: badgeLabel != null ? true : showBadge,
//         child: IconButton(
//             onPressed: onPressed,
//             icon: Icon(icon,
//                 color: iconColor ??
//                     (isDarkTheme(context)
//                         ? AppColors.white
//                         : AppColors.grey100),
//                 size: size)),
//       ),
//     );
//   }
// }
