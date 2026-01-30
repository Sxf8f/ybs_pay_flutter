import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/appBloc/appBloc.dart';
import '../../../core/bloc/appBloc/appState.dart';
import '../../../core/const/color_const.dart';
import '../../../main.dart';

/// BannerSlider displays a carousel slider for showcasing banners.
class BannerSlider extends StatelessWidget {
  /// Constructor for the BannerSlider widget.
  const BannerSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      buildWhen: (previous, current) => current is AppLoaded,
      builder: (context, state) {
        if (state is AppLoaded &&
            state.banners != null &&
            state.banners!.isNotEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: scrWidth * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: CarouselSlider.builder(
                    itemCount: state.banners!.length,
                    itemBuilder:
                        (BuildContext context, int index, int pageViewIndex) {
                          final banner = state.banners![index];
                          // API returns full URL, use directly
                          final imageUrl = banner.image;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.black.withOpacity(0.25)
                                        : Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  memCacheWidth: (scrWidth * 2).toInt(), // Optimize memory usage
                                  placeholder: (context, url) => Container(
                                    height: scrWidth * 0.4,
                                    color: Theme.of(context)
                                            .colorScheme
                                            .surface
                                            .withOpacity(0.6),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          colorConst.primaryColor1,
                                        ),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) {
                                    return Container(
                                      height: scrWidth * 0.4,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surface
                                          .withOpacity(0.6),
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Theme.of(context)
                                            .iconTheme
                                            .color
                                            ?.withOpacity(0.6),
                                        size: 50,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                    options: CarouselOptions(
                      autoPlay:
                          state.banners!.length >
                          1, // Only auto-play if 2+ images
                      viewportFraction: 0.92,
                      height: scrWidth * 0.4,
                      enableInfiniteScroll:
                          state.banners!.length >
                          1, // Only infinite scroll if 2+ images
                      autoPlayInterval: Duration(seconds: 4),
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
