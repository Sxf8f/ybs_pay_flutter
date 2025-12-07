// import 'package:flutter/material.dart';
//
//
// // A circular progress indicator widget.
// ///
// /// The `CustomLoader` class is a convenience class that wraps the `CircularProgressIndicator`
// /// widget and provides additional functionality and customization options. It is commonly used
// /// to show the progress of an ongoing operation and provide visual feedback to the user.
// ///
// class CustomLoader extends StatelessWidget {
//   final Color color; // The color of the circular indicator.
//   final double size; // The size of the circular indicator.
//   final double stroke; // The width of the circular indicator's stroke.
//
//   /// Creates a circular progress indicator with the specified properties.
//   ///
//   /// The [size] parameter specifies the diameter of the indicator. The default size
//   /// is 20.0 pixels.
//   ///
//   /// The [color] parameter specifies the color of the indicator. The default color
//   /// is [AppColors.primary].
//   ///
//   /// The [strokeWidth] parameter specifies the width of the indicator's stroke. The
//   /// default value is 2.0 pixels.
//   const CustomLoader(
//       {super.key,
//       this.color = AppColors.primary,
//       this.size = 20,
//       this.stroke = 2});
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: size,
//       width: size,
//       child: CircularProgressIndicator(
//         valueColor: AlwaysStoppedAnimation<Color>(color),
//         strokeWidth: stroke,
//       ),
//     );
//   }
// }
