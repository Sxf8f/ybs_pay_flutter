// lib/blocs/layout/layout_event.dart
import 'package:equatable/equatable.dart';

abstract class LayoutEvent extends Equatable {
  const LayoutEvent();

  @override
  List<Object?> get props => [];
}

class FetchLayoutsEvent extends LayoutEvent {}
