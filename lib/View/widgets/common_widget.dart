import 'package:flutter/material.dart';

/*
 * Date Calender Theme
 * */
Widget dateTheme(BuildContext context, Widget? child) {
  return Theme(
    data: ThemeData(
      colorScheme: ColorScheme.light(primary: Theme.of(context).primaryColor),
    ),
    child: child!,
  );
}
