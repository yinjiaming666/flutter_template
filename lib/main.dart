import 'package:app/global_app_state.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/l10n/l10n.dart';
import 'package:app/router.dart';
import 'package:app/tool/app_language.dart';
import 'package:app/tool/shared_preferences.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final SharedPreferencesHelper sharedPreferencesInstance =
    SharedPreferencesHelper();
final GlobalAppState globalAppStateInstance = GlobalAppState(
  sharedPreferencesInstance,
);
final appLanguageController = AppLanguageController(sharedPreferencesInstance);
final EventBus globalEventBus = EventBus();
final Logger logger = Logger();

AppLocalizations get currentAppLocalizations =>
    navigatorKey.currentContext?.l10n ?? defaultAppLocalizations;

Future<void> _init() async {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.level = Level.info;
  await sharedPreferencesInstance.init();
  globalAppStateInstance.restore();
  Routes.configureRoutes();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

Future<void> main() async {
  await _init();
  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => const MyApp(),
    ),
  );
}

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    foregroundColor: Colors.black,
  ),
  highlightColor: Colors.transparent,
  splashColor: Colors.transparent,
  primaryColor: Colors.white,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromRGBO(157, 117, 227, 1),
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: globalAppStateInstance),
        ChangeNotifierProvider.value(value: appLanguageController),
      ],
      child: Consumer<AppLanguageController>(
        builder: (context, languages, child) => MaterialApp(
          onGenerateTitle: (context) => context.l10n.appTitle,
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          locale: languages.language.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          navigatorKey: navigatorKey,
          onGenerateRoute: Routes.generateRoute,
          onGenerateInitialRoutes: Routes.generateInitialRoutes,
          navigatorObservers: [AppRouteObserver().routeObserver],
        ),
      ),
    );
  }
}
