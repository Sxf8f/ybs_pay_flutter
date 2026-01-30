import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
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
import 'core/bloc/popupBloc/popupBloc.dart';
import 'core/repository/popupRepository/popupRepo.dart';
import 'core/auth/tokenRefreshService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/repository/distributorRepository/distributorRepo.dart';
import 'core/bloc/distributorBloc/distributorDashboardBloc.dart';
import 'core/bloc/distributorBloc/distributorUserBloc.dart';
import 'core/bloc/distributorBloc/distributorReportBloc.dart';
import 'core/bloc/distributorBloc/distributorCommissionBloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/fcm_service.dart';
import 'core/navigation/appNavigator.dart';
import 'core/theme/theme_manager.dart';
import 'core/theme/theme_manager.dart' as theme;

var scrWidth;
var scrHeight;

// FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   // await initNotifications();
//   // final savedThemeMode = await AdaptiveTheme.getThemeMode();
//   runApp(ProviderScope(child: const MyApp()));
// }
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized');

    // Initialize FCM service
    await FCMService().initialize();
    print('✅ FCM service initialized');
  } catch (e) {
    print('⚠️ Firebase initialization error: $e');
    print('⚠️ Please ensure Firebase is properly configured');
    print('⚠️ Generate firebase_options.dart using: flutterfire configure');
    // Continue app startup even if Firebase fails
  }

  // Start token refresh service if user is logged in
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('access_token');
  if (accessToken != null && accessToken.isNotEmpty) {
    TokenRefreshService.start();

    // Register FCM token if user is already logged in
    try {
      await FCMService().registerPendingToken();
    } catch (e) {
      print('⚠️ Error registering FCM token: $e');
    }
  }

  final layoutRepository = LayoutRepository();
  final userRepository = UserRepository();
  final appRepository = AppRepository();
  final notificationRepository = NotificationRepository();
  final distributorRepository = DistributorRepository();
  final themeManager = ThemeManager();

  runApp(
    ProviderScope(
      child: MultiBlocProvider(
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
            create: (context) => NotificationBloc(
              notificationRepository: notificationRepository,
            ),
          ),
          BlocProvider(create: (context) => PopupBloc(PopupRepository())),
          // Distributor BLoCs
          BlocProvider(
            create: (context) =>
                DistributorDashboardBloc(distributorRepository),
          ),
          BlocProvider(
            create: (context) => DistributorUserBloc(distributorRepository),
          ),
          BlocProvider(
            create: (context) => DistributorReportBloc(distributorRepository),
          ),
          BlocProvider(
            create: (context) =>
                DistributorCommissionBloc(distributorRepository),
          ),
        ],
        child: MyApp(themeManager: themeManager),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ThemeManager themeManager;

  const MyApp({super.key, required this.themeManager});

  @override
  Widget build(BuildContext context) {
    scrWidth = MediaQuery.of(context).size.width;
    scrHeight = MediaQuery.of(context).size.height;
    return ListenableBuilder(
      listenable: themeManager,
      builder: (context, _) {
        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus!.unfocus();
          },
          child: MaterialApp(
            theme: theme.lightTheme,
            darkTheme: theme.darkTheme,
            themeMode: themeManager.themeMode,
            navigatorKey: AppNavigator.navigatorKey,
            home: const splashScreen(),
            builder: (context, child) {
              final isDark = themeManager.themeMode == ThemeMode.dark;
              final style = isDark
                  ? SystemUiOverlayStyle.light.copyWith(
                      statusBarColor: Colors.transparent,
                      statusBarIconBrightness: Brightness.light,
                      statusBarBrightness: Brightness.dark,
                    )
                  : SystemUiOverlayStyle.dark.copyWith(
                      statusBarColor: Colors.transparent,
                      statusBarIconBrightness: Brightness.dark,
                      statusBarBrightness: Brightness.light,
                    );

              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: style,
                child: child ?? const SizedBox.shrink(),
              );
            },
            debugShowCheckedModeBanner: false,
          ),
        );
      },
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
