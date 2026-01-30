import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/models/popupModels/popupModel.dart';
import '../../core/const/assets_const.dart';

class PopupWidget extends StatelessWidget {
  final Popup popup;
  final VoidCallback onDismiss;

  const PopupWidget({
    Key? key,
    required this.popup,
    required this.onDismiss,
  }) : super(key: key);

  Color _hexToColor(String hex) {
    try {
      final hexCode = hex.replaceAll('#', '');
      return Color(int.parse('FF$hexCode', radix: 16));
    } catch (e) {
      return Colors.white; // Default fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _hexToColor(popup.backgroundColor);
    final textColor = _hexToColor(popup.textColor);
    final titleColor = _hexToColor(popup.titleColor);
    final buttonColor = _hexToColor(popup.buttonColor);
    final buttonTextColor = _hexToColor(popup.buttonTextColor);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          image: popup.backgroundImageUrl != null
              ? DecorationImage(
                  image: CachedNetworkImageProvider(
                    popup.backgroundImageUrl!.startsWith('http')
                        ? popup.backgroundImageUrl!
                        : '${AssetsConst.apiBase}${popup.backgroundImageUrl}',
                  ),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: popup.backgroundImageUrl != null
                  ? Colors.black.withOpacity(0.3)
                  : Colors.transparent,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Popup Image (if available)
                  if (popup.imageUrl != null) ...[
                    CachedNetworkImage(
                      imageUrl: popup.imageUrl!.startsWith('http')
                          ? popup.imageUrl!
                          : '${AssetsConst.apiBase}${popup.imageUrl}',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const SizedBox(
                        width: 120,
                        height: 120,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => const SizedBox(
                        width: 120,
                        height: 120,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Title
                  Text(
                    popup.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Content
                  Text(
                    popup.content,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onDismiss,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: buttonTextColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            popup.buttonBorderRadius.toDouble(),
                          ),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        popup.buttonText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

