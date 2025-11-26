import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'features/auth/controller/auth_controller.dart';
import 'features/auth/view/login_page.dart';
import 'features/sample_item_details_view.dart';
import 'features/sample_item_list_view.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  final SettingsController settingsController;

  const MyApp({super.key, required this.settingsController});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => settingsController),
      ],
      child: MaterialApp(
        restorationScopeId: 'app',
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
        ],
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        theme: ThemeData(),
        darkTheme: ThemeData.dark(),
        themeMode: settingsController.themeMode,
        initialRoute: '/login',
        onGenerateRoute: _generateRoutes,
        home: const LoginPage(),
      ),
    );
  }

  Route<dynamic> _generateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case SettingsView.routeName:
        return MaterialPageRoute(
            builder: (_) => SettingsView(controller: settingsController));
      case SampleItemDetailsView.routeName:
        return MaterialPageRoute(builder: (_) => const SampleItemDetailsView());
      case SampleItemListView.routeName:
      default:
        return MaterialPageRoute(builder: (_) => const SampleItemListView());
    }
  }
}
