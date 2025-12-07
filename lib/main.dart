import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ybs_pay/splashScreen.dart';

import 'core/bloc/layoutBloc/layoutBloc.dart';
import 'core/bloc/layoutBloc/layoutEvent.dart';
import 'core/repository/layoutRepository/layoutRepo.dart';
import 'core/bloc/userBloc/userBloc.dart';
import 'core/bloc/userBloc/userEvent.dart';
import 'core/repository/userRepository/userRepo.dart';
import 'core/bloc/appBloc/appBloc.dart';
import 'core/bloc/appBloc/appEvent.dart';
import 'core/repository/appRepository/appRepo.dart';
import 'core/bloc/notificationBloc/notificationBloc.dart';
import 'core/repository/notificationRepository/notificationRepo.dart';

var scrWidth;
var scrHeight;

// FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   // await initNotifications();
//   // final savedThemeMode = await AdaptiveTheme.getThemeMode();
//   runApp(ProviderScope(child: const MyApp()));
// }
void main() {
  final layoutRepository = LayoutRepository();
  final userRepository = UserRepository();
  final appRepository = AppRepository();
  final notificationRepository = NotificationRepository();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              LayoutBloc(layoutRepository)..add(FetchLayoutsEvent()),
        ),
        BlocProvider(
          create: (context) =>
              UserBloc(userRepository)..add(FetchUserDetailsEvent()),
        ),
        BlocProvider(
          create: (context) => AppBloc(appRepository)
            ..add(FetchBannersEvent())
            ..add(FetchSettingsEvent()),
        ),
        BlocProvider(
          create: (context) =>
              NotificationBloc(notificationRepository: notificationRepository),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    scrWidth = MediaQuery.of(context).size.width;
    scrHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus!.unfocus();
      },
      child: MaterialApp(
        // darkTheme: ThemeData.dark(),
        theme: ThemeData(textTheme: GoogleFonts.poppinsTextTheme()),

        home: const splashScreen(),

        // home: const ZigzagReceiptScreen(),

        // home: enterAmountScreen(upiId: 'j'),
        // home: AmountFieldExpanding(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// Future<void> initNotifications() async {
//   const AndroidInitializationSettings initializationSettingsAndroid =
//   AndroidInitializationSettings('@mipmap/launcher_icon');
//
//   final InitializationSettings initializationSettings =
//   InitializationSettings(android: initializationSettingsAndroid);
//
//   await flutterLocalNotificationsPlugin.initialize(initializationSettings);
// }

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
