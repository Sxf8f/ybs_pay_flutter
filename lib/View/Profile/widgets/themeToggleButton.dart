import 'package:flutter/material.dart';
import 'package:ybs_pay/main.dart';
import '../../../core/theme/theme_manager.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager.instance;
    
    return ListenableBuilder(
      listenable: themeManager,
      builder: (context, _) {
        return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.of(context).size.width * 0.14,
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(scrWidth * 0.02),
            color: Theme.of(context).cardColor,
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.shade300,
                blurRadius: 2,
                offset: Offset(3, 3),
                spreadRadius: 1,
              )
            ],
          ),
          child: InkWell(
            onTap: () async {
              await themeManager.toggleTheme();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: scrWidth * 0.04),
                  child: Row(
                    children: [
                      Icon(
                        themeManager.isDarkMode
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        color: Theme.of(context).iconTheme.color,
                        size: 20,
                      ),
                      SizedBox(width: scrWidth * 0.03),
                      Text(
                        themeManager.isDarkMode
                            ? 'Light Theme'
                            : 'Dark Theme',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: MediaQuery.of(context).size.width * 0.032,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: scrWidth * 0.04),
                  child: Switch(
                    value: themeManager.isDarkMode,
                    onChanged: (value) async {
                      await themeManager.setThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
      },
    );
  }
}
