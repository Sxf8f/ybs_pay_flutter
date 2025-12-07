import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/const/assets_const.dart';
import '../../core/const/image_type_const.dart';
/// A widget for displaying images with various types and customization options.
class ImageWidget extends StatelessWidget {
  /// Creates an [ImageWidget] with the specified parameters.
  const ImageWidget(
      {super.key,
      required this.image,
      required this.type,
      this.fit,
      this.backgroundColor,
      this.cachedNetworkImage = false,
      this.placeholder,
      this.height = 50,
      this.width = 50,
      this.borderRadius,
      this.imageColor,
      this.onTap
      });

  /// The image to be displayed.
  final String image;

  /// The type of the image. Possible values are defined in the [ImageType] class.
  final int type;

  /// The fit of the image within its container.
  final BoxFit? fit;

  /// The background color of the container.
  final Color? backgroundColor;

  /// The color of the image.
  final Color? imageColor;

  /// Whether to use cached network image or not. Default is `false`.
  final bool cachedNetworkImage;

  /// The placeholder image to be shown while the main image is loading.
  final String? placeholder;

  /// The height of the container. Default is `50`.
  final double height;

  /// The width of the container. Default is `50`.
  final double width;

  /// The border radius of the container.
  final BorderRadius? borderRadius;

  /// The on tap function of the container
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: height,
        width: width,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: backgroundColor,
        ),
        child: imageWidget(),
      ),
    );
  }

  Widget imageWidget() {
    if (type == ImageType.network) {
      if (cachedNetworkImage) {
        return CachedNetworkImage(
          imageUrl: image,
          fit: fit,
          color: imageColor,
          placeholder: (context, url) => Image.asset(placeholder ?? AssetsConst.logoPlaceholder, fit: BoxFit.cover),
          errorWidget: (context, url, error) => placeholder != null
              ? Image.asset(placeholder ?? '', fit: fit ?? BoxFit.cover)
              : Center(child: Icon(Icons.warning, color: Colors.red.shade600)),
        );
      } else {
        return FadeInImage.assetNetwork(
          placeholder: placeholder ?? '',
          image: image,
          fit: fit,
          placeholderFit: BoxFit.cover,
          imageErrorBuilder: (context, error, stackTrace) => placeholder != null
              ? Image.asset(placeholder ?? AssetsConst.logoPlaceholder, fit: fit ?? BoxFit.cover)
              : Center(child: Icon(Icons.warning, color: Colors.red.shade600)),
        );
      }
    } else if (type == ImageType.asset) {
      return Image.asset(
        image,
        fit: fit,
        color: imageColor,
        errorBuilder: (context, error, stackTrace) => placeholder != null
            ? Image.asset(placeholder ?? AssetsConst.logoPlaceholder, fit: fit ?? BoxFit.cover)
            : Center(child: Icon(Icons.warning, color: Colors.red.shade600)),
      );
    } else {
      return Image.file(
        File(image),
        fit: fit,
        color: imageColor,
        errorBuilder: (context, error, stackTrace) => placeholder != null
            ? Image.asset(placeholder ?? AssetsConst.logoPlaceholder, fit: fit ?? BoxFit.cover)
            : Center(child: Icon(Icons.warning, color: Colors.red.shade600)),
      );
    }
  }
}
