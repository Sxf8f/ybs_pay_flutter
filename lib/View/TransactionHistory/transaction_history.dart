import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ybs_pay/View/TransactionHistory/widgets/filterTransactions.dart';
import 'package:ybs_pay/View/TransactionHistory/widgets/historyListView.dart';
import 'package:ybs_pay/View/TransactionHistory/widgets/statusTabs.dart';
import 'package:ybs_pay/core/const/assets_const.dart';
import 'package:ybs_pay/core/models/transactionModels/transactionModel.dart';
import 'package:ybs_pay/core/bloc/appBloc/appBloc.dart';
import 'package:ybs_pay/core/bloc/appBloc/appState.dart';
import 'package:ybs_pay/main.dart';

class TransactHistory extends StatefulWidget {
  const TransactHistory({super.key});

  @override
  State<TransactHistory> createState() => _TransactHistoryState();
}

class _TransactHistoryState extends State<TransactHistory> {
  String SelectedStatus = 'All';
  String SearchQuery = '';
  bool isLoading = false;
  TransactionResponse? transactionResponse;
  List<Transaction> allTransactions = [];
  Map<int, String> operatorImageMap = {}; // Map operator ID -> image path

  // Filter states
  int? selectedOperatorType;
  int? selectedOperator;
  DateTime? selectedFromDate;
  DateTime? selectedToDate;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login expired. Please log in again.")),
        );
        return;
      }

      // Build query parameters
      Map<String, String> queryParams = {};
      if (selectedOperatorType != null) {
        queryParams['operator_type'] = selectedOperatorType.toString();
      }
      if (selectedOperator != null) {
        queryParams['operator'] = selectedOperator.toString();
      }
      if (selectedFromDate != null) {
        queryParams['start_date'] = selectedFromDate!.toIso8601String().split(
          'T',
        )[0];
      }
      if (selectedToDate != null) {
        queryParams['end_date'] = selectedToDate!.toIso8601String().split(
          'T',
        )[0];
      }
      if (SearchQuery.isNotEmpty) {
        queryParams['search'] = SearchQuery;
      }
      queryParams['limit'] = '50';

      final uri = Uri.parse(
        '${AssetsConst.apiBase}api/recharge-report-android/',
      ).replace(queryParameters: queryParams);

      print('📊 [TRANSACTION_HISTORY] Fetching transactions...');
      print('   📡 API Endpoint: ${uri.toString()}');
      print('   🔑 Query Parameters: $queryParams');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('   📊 Response Status: ${response.statusCode}');
      print('   📏 Response Body Length: ${response.body.length} bytes');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('   ✅ JSON parsed successfully');
        print('   📋 Transactions count: ${data['transactions']?.length ?? 0}');

        // Build operator image map from filters.operators
        final Map<int, String> imageMap = {};
        if (data['filters'] != null && data['filters']['operators'] != null) {
          final operators = data['filters']['operators'] as List;
          print(
            '   🔍 Building operator image map from ${operators.length} operators',
          );
          for (var op in operators) {
            final operatorId = op['id'] as int?;
            final imagePath = op['image']?.toString() ?? '';
            if (operatorId != null && imagePath.isNotEmpty) {
              imageMap[operatorId] = imagePath;
              print('   📝 Operator ID $operatorId -> Image: "$imagePath"');
            }
          }
          print(
            '   ✅ Built operator image map with ${imageMap.length} entries',
          );
        }

        // Debug: Print first transaction details
        if (data['transactions'] != null &&
            (data['transactions'] as List).isNotEmpty) {
          final firstTransaction = (data['transactions'] as List)[0];
          final operatorId = firstTransaction['operator'] as int?;
          final operatorImage = imageMap[operatorId] ?? 'N/A';
          print('   🔍 First transaction:');
          print('      - Operator ID: $operatorId');
          print(
            '      - Operator Name: "${firstTransaction['operator_name']}"',
          );
          print('      - Operator Image (from map): "$operatorImage"');
        }

        setState(() {
          transactionResponse = TransactionResponse.fromJson(data);
          allTransactions = transactionResponse?.transactions ?? [];
          operatorImageMap = imageMap; // Store the image map
        });

        print('   ✅ Loaded ${allTransactions.length} transactions');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to load transactions: ${response.statusCode}",
            ),
          ),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading transactions: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<Transaction> get filteredTransactions {
    return allTransactions.where((txn) {
      final statusMatch =
          SelectedStatus == 'All' ||
          txn.statusName.toLowerCase() == SelectedStatus.toLowerCase();
      final query = SearchQuery.toLowerCase();
      final searchMatch =
          txn.operatorName.toLowerCase().contains(query) ||
          txn.phoneNumber.contains(query) ||
          txn.transactionId.toLowerCase().contains(query) ||
          txn.amount.toString().contains(query);
      return statusMatch && searchMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left: Back arrow + Logo
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.arrow_back_ios,
                              size: 20,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Logo from AppBloc
                          BlocBuilder<AppBloc, AppState>(
                            buildWhen: (previous, current) =>
                                current is AppLoaded,
                            builder: (context, state) {
                              String? logoPath;
                              if (state is AppLoaded &&
                                  state.settings?.logo != null) {
                                logoPath =
                                    "${AssetsConst.apiBase}media/${state.settings!.logo!.image}";
                              }
                              return Container(
                                height: scrWidth * 0.05,
                                child: logoPath != null && logoPath.isNotEmpty
                                    ? Image.network(
                                        logoPath,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return SizedBox.shrink();
                                            },
                                      )
                                    : SizedBox.shrink(),
                              );
                            },
                          ),
                        ],
                      ),
                      // Right: Empty space
                      SizedBox(width: scrWidth * 0.05),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // status Tabs
              statusTabs(
                SelectedStatus: SelectedStatus,
                onSelectedStatus: (Val) {
                  setState(() {
                    SelectedStatus = Val;
                  });
                },
              ),

              // Search and Filter Bar
              TabsClass(
                searchQuery: SearchQuery,
                onSearchChanged: (val) {
                  setState(() {
                    SearchQuery = val;
                  });
                },
                filters: transactionResponse?.filters,
                selectedOperatorType: selectedOperatorType,
                selectedOperator: selectedOperator,
                selectedFromDate: selectedFromDate,
                selectedToDate: selectedToDate,
                onFilterApplied: (filters) {
                  setState(() {
                    // Safely convert filter values
                    final operatorTypeValue = filters['operatorType'];
                    selectedOperatorType = operatorTypeValue is int
                        ? operatorTypeValue
                        : operatorTypeValue is String
                        ? int.tryParse(operatorTypeValue)
                        : null;

                    final operatorValue = filters['operator'];
                    selectedOperator = operatorValue is int
                        ? operatorValue
                        : operatorValue is String
                        ? int.tryParse(operatorValue)
                        : null;

                    selectedFromDate = filters['fromDate'] as DateTime?;
                    selectedToDate = filters['toDate'] as DateTime?;
                  });
                  fetchTransactions();
                },
              ),

              // Transaction List
              if (isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                rechargeHistoryListView(
                  transactions: filteredTransactions,
                  letterpass: SearchQuery,
                  onRefresh: fetchTransactions,
                  operatorImageMap: operatorImageMap, // Pass operator image map
                ),
            ],
          ),
        ),
      ),
    );
  }
}
