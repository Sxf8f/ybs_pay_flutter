import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/const/color_const.dart';


class statusTabs extends StatelessWidget {

  final String SelectedStatus;
  final ValueChanged<String> onSelectedStatus;

   statusTabs({super.key,required this.SelectedStatus,required this.onSelectedStatus});

  // String selectedTransactionType = '';
  //
  // String selectedFilter = 'All';
  //

  @override
  Widget build(BuildContext context) {
    final List<String> filterOptions = ['All', 'Success', 'Failed', 'Pending'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filterOptions.map((filter) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter),
               onSelected: (_) => onSelectedStatus(filter),
                selectedColor: colorConst.primaryColor1.withOpacity(0.2),
                checkmarkColor: colorConst.primaryColor1,
                labelStyle: TextStyle(
                  color: SelectedStatus == filter
                      ? colorConst.primaryColor1
                      : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
                backgroundColor: Colors.grey[100],
                shape: StadiumBorder(
                  side: BorderSide(
                    color: SelectedStatus == filter
                        ? colorConst.primaryColor1
                        : Colors.grey[300]!,
                  ),
                ),
              ),
            );

          }).toList(),
        ),
      ),
    );
  }
}
