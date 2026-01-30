import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/bloc/popupBloc/popupBloc.dart';
import '../../core/bloc/popupBloc/popupEvent.dart';
import '../../core/bloc/popupBloc/popupState.dart';
import '../../core/models/popupModels/popupModel.dart';
import 'popupWidget.dart';

class PopupHandler extends StatefulWidget {
  final Widget child;

  const PopupHandler({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<PopupHandler> createState() => _PopupHandlerState();
}

class _PopupHandlerState extends State<PopupHandler> {
  bool _hasCheckedPopup = false;

  @override
  void initState() {
    super.initState();
    // Check for popup after a short delay to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPopup();
    });
  }

  void _checkPopup() {
    if (!_hasCheckedPopup && mounted) {
      setState(() {
        _hasCheckedPopup = true;
      });
      context.read<PopupBloc>().add(const CheckPopupEvent());
    }
  }

  void _handleDismiss(Popup popup) {
    // If it's a one-time popup, mark it as seen
    if (popup.isOneTime) {
      context.read<PopupBloc>().add(MarkPopupAsSeenEvent(popup.id));
    } else {
      // For every_time popups, just dismiss
      context.read<PopupBloc>().add(const DismissPopupEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PopupBloc, PopupState>(
      listener: (context, state) {
        if (state is PopupMarkedAsSeen || state is PopupDismissed) {
          // Popup has been dismissed, allow app to continue
        }
      },
      child: BlocBuilder<PopupBloc, PopupState>(
        builder: (context, state) {
          return Stack(
            children: [
              // Main app content
              widget.child,
              
              // Popup overlay
              if (state is PopupAvailable)
                PopupWidget(
                  popup: state.popup,
                  onDismiss: () => _handleDismiss(state.popup),
                ),
            ],
          );
        },
      ),
    );
  }
}

