import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'theme/kefi_theme.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Formato de fechas en español
  await initializeDateFormatting('es', null);

  // Persistencia local
  await StorageService.init();

  // Notificaciones push
  await NotificationService.instance.init();

  // Barra de estado blanca sobre fondo azul
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: KefiApp(),
    ),
  );
}

class KefiApp extends StatelessWidget {
  const KefiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kefi',
      theme: KefiTheme.theme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      locale: const Locale('es'),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
