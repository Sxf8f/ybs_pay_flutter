import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:ybs_pay/View/TransactionHistory/widgets/appbar.dart';
import 'package:ybs_pay/View/TransactionHistory/widgets/filterTransactions.dart';
import 'package:ybs_pay/View/TransactionHistory/widgets/historyListView.dart';
import 'package:ybs_pay/View/TransactionHistory/widgets/statusTabs.dart';
import 'package:ybs_pay/core/const/assets_const.dart';
import 'package:ybs_pay/core/models/transactionModels/transactionModel.dart';

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

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          transactionResponse = TransactionResponse.fromJson(data);
          allTransactions = transactionResponse?.transactions ?? [];
        });
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
          appBar: appbartransactionpage(),
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}
