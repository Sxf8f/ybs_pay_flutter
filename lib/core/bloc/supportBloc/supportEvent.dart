import 'package:equatable/equatable.dart';

abstract class SupportEvent extends Equatable {
  const SupportEvent();

  @override
  List<Object> get props => [];
}

class FetchSupportInfoEvent extends SupportEvent {
  const FetchSupportInfoEvent();
}

