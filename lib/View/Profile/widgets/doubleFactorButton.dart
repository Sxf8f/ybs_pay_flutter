import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/bloc/securityBloc/securityBloc.dart';
import '../../../core/bloc/securityBloc/securityEvent.dart';
import '../../../core/bloc/securityBloc/securityState.dart';
import '../../../main.dart';

class doubleFactorApi extends StatefulWidget {
  const doubleFactorApi({super.key});

  @override
  State<doubleFactorApi> createState() => _doubleFactorApiState();
}

class _doubleFactorApiState extends State<doubleFactorApi> {
  @override
  void initState() {
    super.initState();
    // Fetch status when widget loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SecurityBloc>().add(FetchDoubleFactorStatus());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SecurityBloc, SecurityState>(
      listener: (context, state) {
        if (state is SecurityError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is DoubleFactorToggled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.response.message),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: BlocBuilder<SecurityBloc, SecurityState>(
        builder: (context, state) {
          bool isEnabled = false;
          bool isLoading = state is SecurityLoading;

          if (state is DoubleFactorStatusLoaded) {
            isEnabled = state.status.doubleFactorEnabled;
          } else if (state is DoubleFactorToggled) {
            isEnabled = state.response.doubleFactorEnabled;
          }

          return Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8, left: 16, right: 16),
            child: Container(
              width: MediaQuery.of(context).size.width * 1,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.01),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 24,
                      top: 15,
                      bottom: 15,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lock_outline, color: Colors.grey, size: 20),
                            Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: SizedBox(
                                width: scrWidth * 0.55,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Double Factor",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                        fontSize: MediaQuery.of(context).size.width * 0.035,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Enable/Disable double factor to make secure transactions.",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey,
                                        fontSize: MediaQuery.of(context).size.width * 0.028,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                          width: 40,
                          child: isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    // Toggle double factor
                                    context.read<SecurityBloc>().add(
                                          ToggleDoubleFactor(enabled: !isEnabled),
                                        );
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 150),
                                    width: 40,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: isEnabled ? Colors.green[400] : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          offset: isEnabled ? Offset(2, 2) : Offset(3, 3),
                                          blurRadius: 6,
                                        ),
                                        BoxShadow(
                                          color: Colors.white,
                                          offset: isEnabled ? Offset(-2, -2) : Offset(-4, -4),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                    alignment: isEnabled ? Alignment.centerRight : Alignment.centerLeft,
                                    padding: EdgeInsets.symmetric(horizontal: 1),
                                    child: Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            offset: Offset(2, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
