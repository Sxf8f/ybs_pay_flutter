import 'package:equatable/equatable.dart';

abstract class DistributorFundTransferEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SearchUsersForTransferEvent extends DistributorFundTransferEvent {
  final String? search;
  final int? limit;

  SearchUsersForTransferEvent({
    this.search,
    this.limit,
  });

  @override
  List<Object> get props => [
        if (search != null) search!,
        if (limit != null) limit!,
      ];
}

class FetchAllUsersForTransferEvent extends DistributorFundTransferEvent {
  final int? page;
  final int? limit;

  FetchAllUsersForTransferEvent({
    this.page,
    this.limit,
  });

  @override
  List<Object> get props => [
        if (page != null) page!,
        if (limit != null) limit!,
      ];
}

class FundTransferEvent extends DistributorFundTransferEvent {
  final String receiverId;
  final String amount;
  final String? remark;
  final String? secureKey;

  FundTransferEvent({
    required this.receiverId,
    required this.amount,
    this.remark,
    this.secureKey,
  });

  @override
  List<Object> get props => [
        receiverId,
        amount,
        if (remark != null) remark!,
        if (secureKey != null) secureKey!,
      ];
}

