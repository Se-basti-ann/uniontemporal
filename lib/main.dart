import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniontemporal/providers/supervisor_provider.dart';
import 'package:uniontemporal/screens/supervisor_dashboard_screen.dart';
import 'package:uniontemporal/screens/task_detail_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'providers/location_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => SupervisorProvider()),
      ],
      child: MaterialApp(
        title: 'Gestión de Órdenes - UnionTemporal',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF1E88E5),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1E88E5),
            secondary: Color(0xFF00C853),
            surface: Color(0xFFF5F5F5),
          ),
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E88E5),
            elevation: 2,
            titleTextStyle: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          cardTheme: CardTheme(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        routes: {
          '/task-detail': (context) => TaskDetailScreen(
                taskId: ModalRoute.of(context)!.settings.arguments as String,
              ),
        },
        home: Consumer<AuthProvider>(
          builder: (context, auth, child) {
            if (!auth.isAuthenticated) {
              return const LoginScreen();
            } else {              
              final user = auth.user;
              if (user?.role == '2') {
                return const SupervisorDashboardScreen(); // Pantalla para supervisores
              } else {
                return const HomeScreen(); // Pantalla normal para operarios
              }
            }
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
