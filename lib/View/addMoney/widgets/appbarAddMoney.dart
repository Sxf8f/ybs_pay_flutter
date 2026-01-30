import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/const/color_const.dart';
import '../../../core/const/assets_const.dart';
import '../../../core/bloc/appBloc/appBloc.dart';
import '../../../core/bloc/appBloc/appState.dart';
import '../../../core/bloc/appBloc/appEvent.dart';
import '../../../main.dart';
import '../../notification/notificationScreen.dart';



/// A StatelessWidget that represents the app bar used in the add money app screen.


class appBarAddMoney extends StatefulWidget implements PreferredSizeWidget{
  const appBarAddMoney({super.key});
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  State<appBarAddMoney> createState() => _appBarAddMoneyState();
}

class _appBarAddMoneyState extends State<appBarAddMoney> {
  @override
  void initState() {
    super.initState();
    // Fetch settings once on initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AppBloc>().add(FetchSettingsEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      elevation: 0,
      iconTheme: IconThemeData(
        color:  Colors.black,
      ),
      // backgroundColor: _isNightMode?Colors.black: Colors.white,
      actions: [
        SizedBox(
          width: MediaQuery.of(context).size.width*1,
          child: Padding(
            padding: const EdgeInsets.only(right: 18.0,left: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BlocBuilder<AppBloc, AppState>(
                  buildWhen: (previous, current) => current is AppLoaded,
                  builder: (context, state) {
                    String logoPath = "assets/images/ybs.jpeg";
                    if (state is AppLoaded && state.settings?.logo != null) {
                      logoPath =
                          "${AssetsConst.apiBase}media/${state.settings!.logo!.image}";
                    }
                    return Container(
                      height: MediaQuery.of(context).size.width * 0.05,
                      child: Row(
                        children: [
                          logoPath.startsWith('http')
                              ? Image.network(
                                  logoPath,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      "assets/images/ybs.jpeg",
                                    );
                                  },
                                )
                              : Image.asset("assets/images/ybs.jpeg"),
                        ],
                      ),
                    );
                  },
                ),
                Row(
                  children: [
                    SizedBox(width: scrWidth*0.02,),

                    Stack(
                      children: [

                        SizedBox(
                          height: 50,
                          width: 50,
                          child: InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => notificationScreen(),));
                              },
                              child: Icon(Icons.notifications,size: 30,color: colorConst.primaryColor1,)),
                        ),

                        Positioned(
                          top: scrWidth * 0.025,
                          right: scrWidth * 0.015,
                          child: CircleAvatar(
                            backgroundColor: colorConst.primaryColor3,
                            radius: scrWidth * 0.025,
                            child: Center(
                              child: Text(
                                '6',
                                // meatDetailCollection.length.toString(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: scrWidth * 0.03),
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ],
                ),


              ],
            ),
          ),
        ),

      ],
    );
  }
}
