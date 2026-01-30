import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ybs_pay/main.dart';

import '../../../core/const/color_const.dart';
import '../../../core/models/transactionModels/transactionModel.dart';

class TabsClass extends StatefulWidget {
  final String searchQuery;
  final Function(String) onSearchChanged;
  final Function(Map<String, dynamic>)? onFilterApplied;
  final Filters? filters;
  final int? selectedOperatorType;
  final int? selectedOperator;
  final DateTime? selectedFromDate;
  final DateTime? selectedToDate;

  TabsClass({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    this.onFilterApplied,
    this.filters,
    this.selectedOperatorType,
    this.selectedOperator,
    this.selectedFromDate,
    this.selectedToDate,
  });

  @override
  State<TabsClass> createState() => _PaddingState();
}

class _PaddingState extends State<TabsClass> {
  late DateTime? selectedFromDate;
  late DateTime? selectedToDate;
  late int? selectedOperatorType;
  late int? selectedOperator;

  @override
  void initState() {
    super.initState();
    selectedFromDate = widget.selectedFromDate;
    selectedToDate = widget.selectedToDate;
    selectedOperatorType = widget.selectedOperatorType;
    selectedOperator = widget.selectedOperator;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Text(
                    "Filter Transactions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorConst.primaryColor1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      children: [
                        // Operator Type Filter
                        if (widget.filters?.operatorTypes != null)
                          _buildOperatorTypeSection(
                            widget.filters!.operatorTypes,
                            selectedOperatorType,
                            (value) {
                              setModalState(() {
                                selectedOperatorType = value;
                                selectedOperator =
                                    null; // Reset operator when type changes
                              });
                            },
                          ),
                        const SizedBox(height: 24),

                        // Operator Filter (filtered by selected operator type)
                        if (widget.filters?.operators != null &&
                            selectedOperatorType != null)
                          _buildOperatorSection(
                            widget.filters!.operators
                                .where(
                                  (op) => op.typeId == selectedOperatorType,
                                )
                                .toList(),
                            selectedOperator,
                            (value) {
                              setModalState(() {
                                selectedOperator = value;
                              });
                            },
                          ),
                        if (widget.filters?.operators != null &&
                            selectedOperatorType != null)
                          const SizedBox(height: 24),
                        Text(
                          "Date Range",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        selectedFromDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          dialogBackgroundColor: Colors.white,
                                          colorScheme: ColorScheme.light(
                                            primary: colorConst.primaryColor1,
                                            onPrimary: Colors.white,
                                            onSurface: Colors.black,
                                            surface: Colors.white,
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  colorConst.primaryColor1,
                                            ),
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (picked != null) {
                                    setModalState(() {
                                      selectedFromDate = picked;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    selectedFromDate != null
                                        ? "${selectedFromDate!.day}/${selectedFromDate!.month}/${selectedFromDate!.year}"
                                        : "From Date",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        selectedToDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          dialogBackgroundColor: Colors.white,
                                          colorScheme: ColorScheme.light(
                                            primary: colorConst.primaryColor1,
                                            onPrimary: Colors.white,
                                            onSurface: Colors.black,
                                            surface: Colors.white,
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  colorConst.primaryColor1,
                                            ),
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (picked != null) {
                                    setModalState(() {
                                      selectedToDate = picked;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    selectedToDate != null
                                        ? "${selectedToDate!.day}/${selectedToDate!.month}/${selectedToDate!.year}"
                                        : "To Date",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            // Apply filtering logic
                            if (widget.onFilterApplied != null) {
                              widget.onFilterApplied!({
                                'operatorType': selectedOperatorType,
                                'operator': selectedOperator,
                                'fromDate': selectedFromDate,
                                'toDate': selectedToDate,
                              });
                            }
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorConst.primaryColor1,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Apply Filters",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOperatorTypeSection(
    List<OperatorType> options,
    int? selectedValue,
    ValueChanged<int?> onSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Operator Type",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // "All" option
            ChoiceChip(
              label: Text("All"),
              selected: selectedValue == null,
              onSelected: (selected) {
                if (selected) {
                  onSelected(null);
                }
              },
              selectedColor: colorConst.primaryColor1.withOpacity(0.2),
              labelStyle: TextStyle(
                color: selectedValue == null
                    ? colorConst.primaryColor1
                    : Colors.grey[700],
              ),
              backgroundColor: Colors.grey[100],
              shape: StadiumBorder(
                side: BorderSide(
                  color: selectedValue == null
                      ? colorConst.primaryColor1
                      : Colors.grey[300]!,
                ),
              ),
            ),
            // Operator type options
            ...options.map((option) {
              return ChoiceChip(
                label: Text(option.name),
                selected: selectedValue == option.id,
                onSelected: (selected) {
                  if (selected) {
                    onSelected(option.id);
                  } else {
                    onSelected(null);
                  }
                },
                selectedColor: colorConst.primaryColor1.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: selectedValue == option.id
                      ? colorConst.primaryColor1
                      : Colors.grey[700],
                ),
                backgroundColor: Colors.grey[100],
                shape: StadiumBorder(
                  side: BorderSide(
                    color: selectedValue == option.id
                        ? colorConst.primaryColor1
                        : Colors.grey[300]!,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  Widget _buildOperatorSection(
    List<Operator> options,
    int? selectedValue,
    ValueChanged<int?> onSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Operator",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // "All" option
            ChoiceChip(
              label: Text("All"),
              selected: selectedValue == null,
              onSelected: (selected) {
                if (selected) {
                  onSelected(null);
                }
              },
              selectedColor: colorConst.primaryColor1.withOpacity(0.2),
              labelStyle: TextStyle(
                color: selectedValue == null
                    ? colorConst.primaryColor1
                    : Colors.grey[700],
              ),
              backgroundColor: Colors.grey[100],
              shape: StadiumBorder(
                side: BorderSide(
                  color: selectedValue == null
                      ? colorConst.primaryColor1
                      : Colors.grey[300]!,
                ),
              ),
            ),
            // Operator options
            ...options.map((option) {
              return ChoiceChip(
                label: Text(option.name),
                selected: selectedValue == option.id,
                onSelected: (selected) {
                  if (selected) {
                    onSelected(option.id);
                  } else {
                    onSelected(null);
                  }
                },
                selectedColor: colorConst.primaryColor1.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: selectedValue == option.id
                      ? colorConst.primaryColor1
                      : Colors.grey[700],
                ),
                backgroundColor: Colors.grey[100],
                shape: StadiumBorder(
                  side: BorderSide(
                    color: selectedValue == option.id
                        ? colorConst.primaryColor1
                        : Colors.grey[300]!,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search transactions...",
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: scrWidth * 0.03,
                    ),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onChanged: widget.onSearchChanged,
                ),
              ),
              IconButton(
                icon: Icon(Icons.filter_list, color: colorConst.primaryColor1),
                onPressed: _showFilterBottomSheet,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
