import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ybs_pay/View/Support/widgets/accouts&finance.dart';
import 'package:ybs_pay/View/Support/widgets/addressBox.dart';
import 'package:ybs_pay/View/Support/widgets/bankDetails.dart';
import 'package:ybs_pay/View/Support/widgets/customerCare.dart';
import 'package:ybs_pay/View/Support/widgets/facebook.dart';
import 'package:ybs_pay/View/Support/widgets/instagram.dart';
import 'package:ybs_pay/View/Support/widgets/mobileAndDthTollFree.dart';
import 'package:ybs_pay/View/Support/widgets/privacyPolicy.dart';
import 'package:ybs_pay/View/Support/widgets/websiteBox.dart';
import 'package:ybs_pay/View/Support/widgets/x.dart';
import 'package:ybs_pay/View/widgets/app_bar.dart';

import '../../core/bloc/supportBloc/supportBloc.dart';
import '../../core/bloc/supportBloc/supportEvent.dart';
import '../../core/bloc/supportBloc/supportState.dart';
import '../../core/repository/supportRepository/supportRepo.dart';
import '../../core/const/color_const.dart';
import '../../main.dart';

class supportsScreen extends StatefulWidget {
  const supportsScreen({super.key});

  @override
  State<supportsScreen> createState() => _supportsScreenState();
}

class _supportsScreenState extends State<supportsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SupportBloc(SupportRepository())..add(const FetchSupportInfoEvent()),
      child: BlocListener<SupportBloc, SupportState>(
        listener: (context, state) {
          if (state is SupportError) {
            print('Support Error Listener: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: appBar(),
          body: BlocBuilder<SupportBloc, SupportState>(
            builder: (context, state) {
              print('Support Screen State: ${state.runtimeType}');

              if (state is SupportLoading) {
                return _buildSkeletonLoader();
              }

              if (state is SupportError) {
                print('Support Error: ${state.message}');
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'Failed to load support information',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            context.read<SupportBloc>().add(
                              const FetchSupportInfoEvent(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorConst.primaryColor1,
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is SupportLoaded) {
                print('Support Data Loaded: ${state.data}');

                // Check if any data exists
                final hasCustomerCare =
                    state.data.customerCare.mobile.isNotEmpty ||
                    state.data.customerCare.phone.isNotEmpty ||
                    state.data.customerCare.whatsapp.isNotEmpty;
                final hasAccountsFinance =
                    state.data.accountsFinance.mobile.isNotEmpty ||
                    state.data.accountsFinance.phone.isNotEmpty ||
                    state.data.accountsFinance.whatsapp.isNotEmpty;
                final hasSocialMedia =
                    (state.data.socialMedia.facebook.enabled &&
                        state.data.socialMedia.facebook.url.isNotEmpty) ||
                    (state.data.socialMedia.instagram.enabled &&
                        state.data.socialMedia.instagram.url.isNotEmpty) ||
                    (state.data.socialMedia.twitterX.enabled &&
                        state.data.socialMedia.twitterX.url.isNotEmpty);
                final hasWebsite =
                    state.data.website.enabled &&
                    state.data.website.url.isNotEmpty;
                final hasAddress =
                    state.data.address.enabled &&
                    state.data.address.fullAddress.isNotEmpty;
                final hasTollFree =
                    state.data.tollFree.mobile.isNotEmpty ||
                    state.data.tollFree.dth.isNotEmpty;
                final hasBankDetails =
                    state.data.bankDetails.enabled &&
                    (state.data.bankDetails.bankName.isNotEmpty ||
                        state.data.bankDetails.accountNumber.isNotEmpty);
                final hasLegal =
                    (state.data.legal.privacyPolicy.enabled &&
                        state.data.legal.privacyPolicy.url.isNotEmpty) ||
                    (state.data.legal.termsConditions.enabled &&
                        state.data.legal.termsConditions.url.isNotEmpty);

                final hasAnyData =
                    hasCustomerCare ||
                    hasAccountsFinance ||
                    hasSocialMedia ||
                    hasWebsite ||
                    hasAddress ||
                    hasTollFree ||
                    hasBankDetails ||
                    hasLegal;

                return SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(scrWidth * 0.04),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(
                                color: colorConst.primaryColor1.withOpacity(
                                  0.2,
                                ),
                                width: 2,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(scrWidth * 0.025),
                                    decoration: BoxDecoration(
                                      color: colorConst.primaryColor1
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(
                                        scrWidth * 0.01,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.support_agent,
                                      color: colorConst.primaryColor1,
                                      size: scrWidth * 0.05,
                                    ),
                                  ),
                                  SizedBox(width: scrWidth * 0.03),
                                  Text(
                                    'Contact Us',
                                    style: TextStyle(
                                      fontSize: scrWidth * 0.04,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: scrWidth * 0.02),
                              Text(
                                'Get in touch with our support team',
                                style: TextStyle(
                                  fontSize: scrWidth * 0.028,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: scrWidth * 0.04),

                        // Show message if no data is available
                        if (!hasAnyData)
                          Padding(
                            padding: EdgeInsets.all(scrWidth * 0.04),
                            child: Container(
                              padding: EdgeInsets.all(scrWidth * 0.06),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(
                                  scrWidth * 0.01,
                                ),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(scrWidth * 0.03),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.info_outline,
                                      size: scrWidth * 0.08,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: scrWidth * 0.04),
                                  Text(
                                    'Support information is being configured.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: scrWidth * 0.033,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  SizedBox(height: scrWidth * 0.02),
                                  Text(
                                    'Please check back later.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: scrWidth * 0.028,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        if (!hasAnyData) SizedBox(height: scrWidth * 0.04),

                        // Content Section
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: scrWidth * 0.04,
                          ),
                          child: Column(
                            children: [
                              /// Customer Care
                              if (state.data.customerCare.mobile.isNotEmpty ||
                                  state.data.customerCare.phone.isNotEmpty ||
                                  state.data.customerCare.whatsapp.isNotEmpty)
                                customerCareBox(data: state.data.customerCare),
                              if (state.data.customerCare.mobile.isNotEmpty ||
                                  state.data.customerCare.phone.isNotEmpty ||
                                  state.data.customerCare.whatsapp.isNotEmpty)
                                SizedBox(height: scrWidth * 0.04),

                              /// Accounts and Finance
                              if (state
                                      .data
                                      .accountsFinance
                                      .mobile
                                      .isNotEmpty ||
                                  state.data.accountsFinance.phone.isNotEmpty ||
                                  state
                                      .data
                                      .accountsFinance
                                      .whatsapp
                                      .isNotEmpty)
                                accountsFinanceBox(
                                  data: state.data.accountsFinance,
                                ),
                              if (state
                                      .data
                                      .accountsFinance
                                      .mobile
                                      .isNotEmpty ||
                                  state.data.accountsFinance.phone.isNotEmpty ||
                                  state
                                      .data
                                      .accountsFinance
                                      .whatsapp
                                      .isNotEmpty)
                                SizedBox(height: scrWidth * 0.04),

                              /// Facebook
                              if (state.data.socialMedia.facebook.enabled &&
                                  state
                                      .data
                                      .socialMedia
                                      .facebook
                                      .url
                                      .isNotEmpty)
                                facebookBox(
                                  url: state.data.socialMedia.facebook.url,
                                ),
                              if (state.data.socialMedia.facebook.enabled &&
                                  state
                                      .data
                                      .socialMedia
                                      .facebook
                                      .url
                                      .isNotEmpty)
                                SizedBox(height: scrWidth * 0.04),

                              /// Instagram
                              if (state.data.socialMedia.instagram.enabled &&
                                  state
                                      .data
                                      .socialMedia
                                      .instagram
                                      .url
                                      .isNotEmpty)
                                instagramBox(
                                  url: state.data.socialMedia.instagram.url,
                                ),
                              if (state.data.socialMedia.instagram.enabled &&
                                  state
                                      .data
                                      .socialMedia
                                      .instagram
                                      .url
                                      .isNotEmpty)
                                SizedBox(height: scrWidth * 0.04),

                              /// Twitter X
                              if (state.data.socialMedia.twitterX.enabled &&
                                  state
                                      .data
                                      .socialMedia
                                      .twitterX
                                      .url
                                      .isNotEmpty)
                                twitterXBox(
                                  url: state.data.socialMedia.twitterX.url,
                                ),
                              if (state.data.socialMedia.twitterX.enabled &&
                                  state
                                      .data
                                      .socialMedia
                                      .twitterX
                                      .url
                                      .isNotEmpty)
                                SizedBox(height: scrWidth * 0.04),

                              /// Website
                              if (state.data.website.enabled &&
                                  state.data.website.url.isNotEmpty)
                                websiteBox(url: state.data.website.url),
                              if (state.data.website.enabled &&
                                  state.data.website.url.isNotEmpty)
                                SizedBox(height: scrWidth * 0.04),

                              /// Address
                              if (state.data.address.enabled &&
                                  state.data.address.fullAddress.isNotEmpty)
                                addressBox(
                                  address: state.data.address.fullAddress,
                                ),
                              if (state.data.address.enabled &&
                                  state.data.address.fullAddress.isNotEmpty)
                                SizedBox(height: scrWidth * 0.04),

                              /// Mobile toll free and dth toll free
                              if (state.data.tollFree.mobile.isNotEmpty ||
                                  state.data.tollFree.dth.isNotEmpty)
                                mobileAndDthTollFreeBox(
                                  mobileTollFree: state.data.tollFree.mobile,
                                  dthTollFree: state.data.tollFree.dth,
                                ),
                              if (state.data.tollFree.mobile.isNotEmpty ||
                                  state.data.tollFree.dth.isNotEmpty)
                                SizedBox(height: scrWidth * 0.04),

                              /// Bank Details
                              if (state.data.bankDetails.enabled &&
                                  (state.data.bankDetails.bankName.isNotEmpty ||
                                      state
                                          .data
                                          .bankDetails
                                          .accountNumber
                                          .isNotEmpty))
                                bankDetailsBox(data: state.data.bankDetails),
                              if (state.data.bankDetails.enabled &&
                                  (state.data.bankDetails.bankName.isNotEmpty ||
                                      state
                                          .data
                                          .bankDetails
                                          .accountNumber
                                          .isNotEmpty))
                                SizedBox(height: scrWidth * 0.04),

                              /// Privacy Policy
                              if ((state.data.legal.privacyPolicy.enabled &&
                                      state
                                          .data
                                          .legal
                                          .privacyPolicy
                                          .url
                                          .isNotEmpty) ||
                                  (state.data.legal.termsConditions.enabled &&
                                      state
                                          .data
                                          .legal
                                          .termsConditions
                                          .url
                                          .isNotEmpty))
                                privacyPolicyTermsConditionsBox(
                                  privacyPolicyUrl:
                                      state.data.legal.privacyPolicy.url,
                                  termsConditionsUrl:
                                      state.data.legal.termsConditions.url,
                                  privacyPolicyEnabled:
                                      state.data.legal.privacyPolicy.enabled,
                                  termsConditionsEnabled:
                                      state.data.legal.termsConditions.enabled,
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: scrWidth * 0.15),
                      ],
                    ),
                  ),
                );
              }

              // SupportInitial state - show loading initially
              return _buildSkeletonLoader();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(scrWidth * 0.04),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: colorConst.primaryColor1.withOpacity(0.2),
                  width: 2,
                ),
              ),
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: scrWidth * 0.1,
                        height: scrWidth * 0.1,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(scrWidth * 0.01),
                        ),
                      ),
                      SizedBox(width: scrWidth * 0.03),
                      Container(
                        width: scrWidth * 0.3,
                        height: scrWidth * 0.04,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: scrWidth * 0.02),
                  Container(
                    width: scrWidth * 0.5,
                    height: scrWidth * 0.028,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: scrWidth * 0.04),
          // Content skeleton
          Padding(
            padding: EdgeInsets.symmetric(horizontal: scrWidth * 0.04),
            child: Column(
              children: List.generate(6, (index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: scrWidth * 0.04),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: scrWidth * 0.25,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(scrWidth * 0.02),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
