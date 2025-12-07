// import 'package:flutter/material.dart';
// import 'package:ybs_pay/View/widgets/spacing.dart';
//
// import 'custom_loader.dart';
//
//
// class CustomButton extends StatelessWidget {
//   const CustomButton({
//     super.key,
//     required this.title,
//     required this.onTap,
//     this.loading = false,
//     this.color,
//     this.textColor,
//     this.xPadding,
//     this.fontSize,
//     this.fontWeight,
//     this.yPadding,
//     this.enable = true,
//     this.leftIcon,
//     this.rightIcon,
//     this.iconColor,
//     this.iconSize,
//     this.lined,
//     this.borderColor,
//     this.radius,
//     this.elevation,
//   });
//
//   final String title;
//   final Function? onTap;
//   final bool loading;
//   final Color? color;
//   final Color? textColor;
//   final double? xPadding;
//   final double? yPadding;
//   final double? fontSize;
//   final FontWeight? fontWeight;
//   final bool enable;
//   final IconData? leftIcon;
//   final IconData? rightIcon;
//   final Color? iconColor;
//   final double? iconSize;
//   final bool? lined;
//   final double? radius;
//   final double? elevation;
//   final Color? borderColor;
//
//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: enable
//           ? loading
//               ? null
//               : onTap as void Function()?
//           : null,
//       style: ButtonStyle(
//         elevation:
//             WidgetStateProperty.resolveWith((states) => elevation ?? 0),
//         backgroundColor: getBtnBackground(context),
//         padding: WidgetStateProperty.resolveWith((states) =>
//             EdgeInsets.symmetric(
//                 horizontal: xPadding ?? 20, vertical: yPadding ?? 0)),
//         shape: WidgetStateProperty.resolveWith(
//           (states) => RoundedRectangleBorder(
//             side: BorderSide(
//               color: lined == true
//                   ? borderColor ?? Colors.grey.withOpacity(0.3)
//                   : Colors.transparent,
//               width: lined == true ? 1 : 0,
//             ),
//             borderRadius: BorderRadius.circular(radius ?? 15),
//           ),
//         ),
//       ),
//       child: loading
//           ? CustomLoader(color: textColor ?? Theme.of(context).primaryColor)
//           : Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 if (leftIcon != null)
//                   Icon(
//                     leftIcon,
//                     size: iconSize ?? 20,
//                     color: enable == true
//                         ? (iconColor ?? (textColor ?? Colors.white))
//                         : Colors.black.withOpacity(0.6),
//                   ),
//                 if (leftIcon != null) spacing(width: 7),
//                 Text(
//                   title,
//                   style: TextStyle(
//                     color: enable
//                         ? textColor ?? Colors.white
//                         : Colors.black.withOpacity(0.6),
//                     fontSize: fontSize ?? 14,
//                     fontWeight: fontWeight ?? FontWeight.w500,
//                   ),
//                 ),
//                 if (rightIcon != null) spacing(width: 7),
//                 if (rightIcon != null)
//                   Icon(
//                     rightIcon,
//                     size: iconSize ?? 20,
//                     color: enable == true
//                         ? (iconColor ?? (textColor ?? Colors.white))
//                         : Colors.black.withOpacity(0.6),
//                   ),
//               ],
//             ),
//     );
//   }
//
//   WidgetStateProperty<Color> getBtnBackground(BuildContext context) {
//     return WidgetStateProperty.resolveWith(
//       (states) => loading
//           ? AppColors.grey40
//           : enable
//               ? color ?? Theme.of(context).primaryColor
//               : Colors.grey.withOpacity(0.5),
//     );
//   }
// }
