import 'package:equatable/equatable.dart';

abstract class DistributorUserEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchUserListEvent extends DistributorUserEvent {
  final int? page;
  final int? limit;
  final String? search;
  final String? role;
  final String? criteria;
  final String? searchValue;
  final String? phoneNumber;

  FetchUserListEvent({
    this.page,
    this.limit,
    this.search,
    this.role,
    this.criteria,
    this.searchValue,
    this.phoneNumber,
  });

  @override
  List<Object> get props => [
        if (page != null) page!,
        if (limit != null) limit!,
        if (search != null) search!,
        if (role != null) role!,
        if (criteria != null) criteria!,
        if (searchValue != null) searchValue!,
        if (phoneNumber != null) phoneNumber!,
      ];
}

class CreateUserEvent extends DistributorUserEvent {
  final String username;
  final String email;
  final String phoneNumber;
  final String? pincode;
  final String? address;
  final String? outlet;
  final int? roleId; // Optional: 6 for Retailer (default), 3 for API User

  CreateUserEvent({
    required this.username,
    required this.email,
    required this.phoneNumber,
    this.pincode,
    this.address,
    this.outlet,
    this.roleId,
  });

  @override
  List<Object> get props => [
        username,
        email,
        phoneNumber,
        if (pincode != null) pincode!,
        if (address != null) address!,
        if (outlet != null) outlet!,
        if (roleId != null) roleId!,
      ];
}

