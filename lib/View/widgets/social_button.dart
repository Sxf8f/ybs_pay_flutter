// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:ybs_pay/View/widgets/spacing.dart';
//
// import '../../core/themes/colors.dart';
// import '../../core/utils/styles.dart';
//
// /// A custom social button widget.
// ///
// /// This widget displays a social media button with an icon and a label.
// /// It can be used to create buttons for various social media platforms.
// class SocialButton extends StatelessWidget {
//   final String icon; // The icon to display on the button.
//   final String label; // The label to display on the button.
//   final VoidCallback onTap; // The callback function when the button is tapped.
//
//   /// Creates a social button.
//   ///
//   /// The [icon] parameter specifies the icon to display on the button.
//   /// The [label] parameter specifies the label to display on the button.
//   /// The [onTap] parameter specifies the callback function when the button is tapped.
//   const SocialButton(
//       {super.key, required this.icon, required this.label, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(50),
//         child: Container(
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(50),
//               border: Border.all(width: 1.5, color: AppColors.grey40)),
//           padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               SvgPicture.asset(icon, height: 25,),
//               spacing(width: 10),
//               Text(
//                 label,
//                 style: TextStyle(
//                     color: ColorHelper.primaryToWhite(context),
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
