import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/bloc/distributorBloc/distributorCommissionBloc.dart';
import '../../../core/bloc/distributorBloc/distributorCommissionEvent.dart';
import '../../../core/bloc/distributorBloc/distributorCommissionState.dart';
import '../../../core/models/distributorModels/distributorCommissionModel.dart';
import '../../../core/const/color_const.dart';
import '../../../core/const/assets_const.dart';
import '../../../main.dart';
import '../../widgets/app_bar.dart';

class CommissionSlabScreen extends StatefulWidget {
  const CommissionSlabScreen({super.key});

  @override
  State<CommissionSlabScreen> createState() => _CommissionSlabScreenState();
}

class _CommissionSlabScreenState extends State<CommissionSlabScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DistributorCommissionBloc>().add(FetchCommissionSlabEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      backgroundColor: Colors.white,
      body: BlocBuilder<DistributorCommissionBloc, DistributorCommissionState>(
        builder: (context, state) {
          if (state is DistributorCommissionLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is DistributorCommissionError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DistributorCommissionBloc>().add(
                        FetchCommissionSlabEvent(),
                      );
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is DistributorCommissionLoaded) {
            final commission = state.commission;
            return SingleChildScrollView(
              padding: EdgeInsets.all(scrWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Commission Label
                  if (commission.commissionLabel != null)
                    Container(
                      padding: EdgeInsets.all(scrWidth * 0.04),
                      decoration: BoxDecoration(
                        color: colorConst.primaryColor1.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorConst.primaryColor1),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.percent,
                            color: colorConst.primaryColor1,
                            size: scrWidth * 0.06,
                          ),
                          SizedBox(width: scrWidth * 0.03),
                          Expanded(
                            child: Text(
                              commission.commissionLabel!,
                              style: TextStyle(
                                fontSize: scrWidth * 0.04,
                                fontWeight: FontWeight.bold,
                                color: colorConst.primaryColor1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (commission.commissionLabel != null)
                    SizedBox(height: scrWidth * 0.04),

                  // Commission Data
                  Text(
                    'Commission Details',
                    style: TextStyle(
                      fontSize: scrWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: scrWidth * 0.03),

                  if (commission.data.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(scrWidth * 0.05),
                        child: Text(
                          'No commission data available',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    )
                  else
                    ...commission.data
                        .map((data) => _buildCommissionCard(data))
                        .toList(),
                ],
              ),
            );
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildCommissionCard(CommissionData data) {
    return Container(
      margin: EdgeInsets.only(bottom: scrWidth * 0.03),
      padding: EdgeInsets.all(scrWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Operator Icon
                    if (data.operatorIcon != null &&
                        data.operatorIcon!.isNotEmpty)
                      Container(
                        width: scrWidth * 0.12,
                        height: scrWidth * 0.12,
                        margin: EdgeInsets.only(right: scrWidth * 0.03),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                          color: Colors.white,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: _buildImageUrl(data.operatorIcon!),
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade100,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colorConst.primaryColor1,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade100,
                              child: Icon(
                                Icons.business,
                                color: Colors.grey.shade400,
                                size: scrWidth * 0.06,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: scrWidth * 0.12,
                        height: scrWidth * 0.12,
                        margin: EdgeInsets.only(right: scrWidth * 0.03),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                          color: Colors.grey.shade100,
                        ),
                        child: Icon(
                          Icons.business,
                          color: Colors.grey.shade400,
                          size: scrWidth * 0.06,
                        ),
                      ),
                    // Operator Name and Type
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.operatorName,
                            style: TextStyle(
                              fontSize: scrWidth * 0.038,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: scrWidth * 0.01),
                          Text(
                            data.operatorType,
                            style: TextStyle(
                              fontSize: scrWidth * 0.032,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: scrWidth * 0.03,
                  vertical: scrWidth * 0.015,
                ),
                decoration: BoxDecoration(
                  color: colorConst.primaryColor1.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  data.percentageOrFixed == 'Percentage'
                      ? '${data.commissionValue.toStringAsFixed(2)}%'
                      : '₹${data.commissionValue.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: scrWidth * 0.035,
                    fontWeight: FontWeight.bold,
                    color: colorConst.primaryColor1,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: scrWidth * 0.02),
          Divider(),
          SizedBox(height: scrWidth * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem('Commission Type', data.commissionType),
              _buildInfoItem('Type', data.percentageOrFixed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: scrWidth * 0.028, color: Colors.grey[600]),
        ),
        SizedBox(height: scrWidth * 0.005),
        Text(
          value,
          style: TextStyle(
            fontSize: scrWidth * 0.032,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Build the full image URL from operator icon path
  String _buildImageUrl(String operatorIcon) {
    // If the icon already starts with http, return as is
    if (operatorIcon.startsWith('http://') ||
        operatorIcon.startsWith('https://')) {
      return operatorIcon;
    }

    // Remove leading slash if present to avoid double slashes
    String cleanPath = operatorIcon.startsWith('/')
        ? operatorIcon.substring(1)
        : operatorIcon;

    // Combine with base URL
    String baseUrl = AssetsConst.apiBase.endsWith('/')
        ? AssetsConst.apiBase.substring(0, AssetsConst.apiBase.length - 1)
        : AssetsConst.apiBase;

    return '$baseUrl/$cleanPath';
  }
}
