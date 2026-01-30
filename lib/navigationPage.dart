import 'dart:async';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:ybs_pay/View/Reports/reportsScreen.dart';
import 'View/Home/1homeScreen.dart';
import 'View/Profile/profileScreen.dart';
import 'View/Support/supportScreen.dart';
import 'core/const/color_const.dart';
import 'View/popup/popupHandler.dart';
import 'core/bloc/userBloc/userBloc.dart';
import 'core/bloc/userBloc/userState.dart';
import 'core/bloc/userBloc/userEvent.dart';
import 'core/bloc/dashboardBloc/dashboardBloc.dart';
import 'core/bloc/dashboardBloc/dashboardEvent.dart';





























class navigationPage extends StatefulWidget {
  final int initialIndex;
  const navigationPage({super.key, required this.initialIndex});

  @override
  State<navigationPage> createState() => _navigationPageState();
}

class _navigationPageState extends State<navigationPage> {
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  final PageController _pageController = PageController(initialPage: 0);
  // final _pageController = PageController(initialPage: 0);
  int notiCount=0;
  Timer? pollingTimer;




  @override
  void dispose() {
    _pageController.dispose();
    pollingTimer?.cancel();
    ScreenProtector.preventScreenshotOff();
    super.dispose();
  }

  int selectedIndex = 0;
  void onItemTapped(int Index) {
    setState(() {
      selectedIndex = Index;
    });
  }
  int _currentIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // startPolling();
    // fetchUnreadNotifications();
    _currentIndex = widget.initialIndex;
    // ScreenProtector.preventScreenshotOn();
  }
  Widget build(BuildContext context) {
    return PopupHandler(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          maintainBottomViewPadding: true,
          child: Scaffold(
            // appBar: AppBar(
            //   backgroundColor: Colors.white,
            //   scrolledUnderElevation: 0,
            //   automaticallyImplyLeading: false,
            //   elevation: 0,
            //   iconTheme: IconThemeData(
            //     color:  Colors.black,
            //   ),
            //   // backgroundColor: _isNightMode?Colors.black: Colors.white,
            //   actions: [
            //     SizedBox(
            //       width: MediaQuery.of(context).size.width*1,
            //       child: Padding(
            //         padding: const EdgeInsets.only(right: 18.0,left: 25),
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: [
            //             Container(
            //               // color: Colors.grey,
            //               //   width: MediaQuery.of(context).size.width*0.07,
            //                 height: MediaQuery.of(context).size.width*0.05,
            //                 child: Row(
            //                   children: [
            //                     Image.asset("assets/images/ybs.jpeg"),
            //                   ],
            //                 )),
            //             Row(
            //               children: [
            //                 Column(
            //                   mainAxisAlignment: MainAxisAlignment.center,
            //                   children: [
            //                     InkWell(
            //                       onTap: () {
            //                         // boxShadow: [
            //                         //   BoxShadow(
            //                         //       color: Colors.grey.shade300,
            //                         //       blurRadius: 2,
            //                         //       // blurStyle: BlurStyle.outer,
            //                         //       offset: Offset(4, 4),
            //                         //       spreadRadius: 1
            //                         //
            //                         //   )
            //                         // ]
            //                         Navigator.push(context, MaterialPageRoute(builder: (context) => addMoneyScreen(),));
            //                       },
            //                       child: Container(
            //                         decoration: BoxDecoration(
            //                           color: colorConst.primaryColor1,
            //                           borderRadius: BorderRadius.circular(scrWidth*0.015),
            //                           // borderRadius: BorderRadius.only(topRight: )
            //                         ),
            //                         child: Center(
            //                           child: Padding(
            //                             padding: const EdgeInsets.all(7.0),
            //                             child: Text('Add Money',style: TextStyle(
            //                                 fontSize: 11,
            //                                 fontWeight: FontWeight.w600,
            //                                 color: Colors.white
            //                             ),),
            //                           ),
            //                         ),
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //                 SizedBox(width: scrWidth*0.02,),
            //
            //                 Stack(
            //                   children: [
            //
            //                     SizedBox(
            //                       height: 50,
            //                       width: 50,
            //                       child: InkWell(
            //                         onTap: () {
            //                           Navigator.push(context, MaterialPageRoute(builder: (context) => notificationScreen(),));
            //                         },
            //                           child: Icon(Icons.notifications,size: 30,color: colorConst.primaryColor1,)),
            //                     ),
            //
            //                     Positioned(
            //                       top: scrWidth * 0.025,
            //                       right: scrWidth * 0.015,
            //                       child: CircleAvatar(
            //                         backgroundColor: colorConst.primaryColor3,
            //                         radius: scrWidth * 0.025,
            //                         child: Center(
            //                           child: Text(
            //                             '6',
            //                             // meatDetailCollection.length.toString(),
            //                             style: TextStyle(
            //                                 color: Colors.white,
            //                                 fontWeight: FontWeight.w800,
            //                                 fontSize: scrWidth * 0.03),
            //                           ),
            //                         ),
            //                       ),
            //                     ),
            //
            //                   ],
            //                 ),
            //               ],
            //             ),
            //
            //
            //           ],
            //         ),
            //       ),
            //     ),
            //
            //   ],
            // ),
            body: BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                // Determine pages based on role
                List<Widget> pages;

                // For now, use same pages for both (will update when distributor screens are ready)
                // TODO: Replace with distributor-specific screens when created
                pages = [
                  homeScreen(), // Will show distributor dashboard if distributor
                  reportsScreen(), // Will show distributor reports if distributor
                  supportsScreen(),
                  profileScreen(),
                ];
                
                return pages[_currentIndex];
              },
            ),
          extendBody: true,
          backgroundColor: Colors.transparent,
            bottomNavigationBar: CurvedNavigationBar(
              key: _bottomNavigationKey,
              index: _currentIndex,
              height: 60.0,
              items: <Widget>[
                _currentIndex==0?
                Icon(Icons.home, size: 28, color: Colors.white):
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.home, size: 25, color: Colors.white),
                      Text('Home',style: TextStyle(
                        color: Colors.white,
                        fontSize: 11
                      ),)
                    ],
                  ),
                ),

                _currentIndex==1?
                Icon(Icons.note_alt_outlined, size: 28, color: Colors.white):
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.note_alt_outlined, size: 25, color: Colors.white),
                      Text('Reports',style: TextStyle(
                          color: Colors.white,
                          fontSize: 11
                      ),)
                    ],
                  ),
                ),

                _currentIndex==2?
                Icon(Icons.support_agent_sharp, size: 28, color: Colors.white):
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.support_agent_sharp, size: 25, color: Colors.white),
                      Text('Support',style: TextStyle(
                          color: Colors.white,
                          fontSize: 11
                      ),)
                    ],
                  ),
                ),

                _currentIndex==3?
                Icon(Icons.person, size: 28, color: Colors.white):
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.person, size: 25, color: Colors.white),
                      Text('Profile',style: TextStyle(
                          color: Colors.white,
                          fontSize: 11
                      ),)
                    ],
                  ),
                ),

                // Icon(Icons.note_alt_outlined, size: 25, color: Colors.white),
                // Icon(Icons.support_agent_sharp, size: 25, color: Colors.white),
                // Icon(Icons.person_outline_outlined, size: 25, color: Colors.white),
              ],
              // color: Colors.blue.shade900,
              color: colorConst.primaryColor1,
              buttonBackgroundColor: colorConst.primaryColor2,
              backgroundColor: Colors.transparent,
              animationCurve: Curves.easeInOut,
              animationDuration: Duration(milliseconds: 600),
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
                // Refresh only balance and stats when navigating to home screen (index 0)
                if (index == 0) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      try {
                        // Use RefreshBalanceOnlyEvent to preserve profile picture
                        context.read<UserBloc>().add(const RefreshBalanceOnlyEvent());
                        context.read<DashboardBloc>().add(FetchDashboardStatistics(period: 'month'));
                        print('🔄 [NAVIGATION] Refreshing balance and stats on home tab selection');
                      } catch (e) {
                        print('⚠️ [NAVIGATION] Could not refresh balance and stats: $e');
                      }
                    }
                  });
                }
              },

            )


        ),
      ),
    ),
    );
  }
}















// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   late PersistentTabController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = PersistentTabController(initialIndex: 0);
//   }
//
//   List<Widget> _buildScreens() {
//     return [
//       Center(child: Text("Home")),
//       Center(child: Text("Search")),
//       Center(child: Text("Profile")),
//     ];
//   }
//
//   List<PersistentBottomNavBarItem> _navBarsItems() {
//     return [
//       PersistentBottomNavBarItem(
//         icon: NeumorphicIcon(Icons.home, style: NeumorphicStyle(color: Colors.black)),
//         title: "Home",
//         activeColorPrimary: Colors.blueAccent,
//         inactiveColorPrimary: Colors.grey,
//       ),
//       PersistentBottomNavBarItem(
//         icon: NeumorphicIcon(Icons.search, style: NeumorphicStyle(color: Colors.black)),
//         title: "Search",
//         activeColorPrimary: Colors.blueAccent,
//         inactiveColorPrimary: Colors.grey,
//       ),
//       PersistentBottomNavBarItem(
//         icon: NeumorphicIcon(Icons.person, style: NeumorphicStyle(color: Colors.black)),
//         title: "Profile",
//         activeColorPrimary: Colors.blueAccent,
//         inactiveColorPrimary: Colors.grey,
//       ),
//     ];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Neumorphic(
//       style: NeumorphicStyle(
//         depth: -4,
//         intensity: 0.8,
//         surfaceIntensity: 0.15,
//       ),
//       child: PersistentTabView(
//         context,
//         controller: _controller,
//         screens: _buildScreens(),
//         items: _navBarsItems(),
//         navBarStyle: NavBarStyle.style6, // Choose a flat style for better neumorphic feel
//         backgroundColor: NeumorphicTheme.baseColor(context),
//         decoration: NavBarDecoration(
//           borderRadius: BorderRadius.circular(20),
//           colorBehindNavBar: Colors.white,
//         ),
//       ),
//     );
//   }
// }

