import 'package:flutter/material.dart';

/// Creates a sized box with the specified [width] and [height].
///
/// This method is a convenience method that allows you to create a `SizedBox`
/// with both horizontal and vertical constraints. It is commonly used to add
/// spacing or to size widgets in a layout.
///
/// If the [width] or [height] is not provided or set to null, the box will
/// collapse to zero width and height, effectively taking no space within the layout.
SizedBox spacing({double? width, double? height}) {
  return SizedBox(
    width: width ?? 0.0, // Set width to 0 if not provided.
    height: height ?? 0.0, // Set height to 0 if not provided.
  );
}
