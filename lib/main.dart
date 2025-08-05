// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import 'services/auth_service.dart';
// // import 'services/gemini_service.dart';
// // import 'providers/finance_provider.dart';
// // import 'screens/dashboard_screen.dart';
// // import 'screens/login_screen.dart';
// // import 'screens/chat_assistant_screen.dart';
// // import 'screens/microfinance_screen.dart';

// // void main() {
// //   runApp(const FinLinkApp());
// // }

// // class FinLinkApp extends StatelessWidget {
// //   const FinLinkApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MultiProvider(
// //       providers: [
// //         Provider<AuthService>(create: (_) => AuthService()),
// //         Provider<GeminiService>(create: (_) => GeminiService()),
// //         ChangeNotifierProvider(create: (_) => FinanceProvider()),
// //       ],
// //       child: MaterialApp(
// //         debugShowCheckedModeBanner: false,
// //         title: 'FinLink',
// //         theme: ThemeData(
// //           colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
// //           useMaterial3: true,
// //         ),
// //         home: const AuthWrapper(),
// //       ),
// //     );
// //   }
// // }

// // class AuthWrapper extends StatelessWidget {
// //   const AuthWrapper({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     final authService = Provider.of<AuthService>(context);

// //     return StreamBuilder(
// //       stream: authService.authStateChanges,
// //       builder: (context, snapshot) {
// //         if (snapshot.connectionState == ConnectionState.waiting) {
// //           return const Scaffold(
// //             body: Center(child: CircularProgressIndicator()),
// //           );
// //         }
// //         if (snapshot.hasData) {
// //           return const DashboardScreen();
// //         } else {
// //           return const LoginScreen();
// //         }
// //       },
// //     );
// //   }
// // }
// // class DashboardScreen extends StatelessWidget {
// //   const DashboardScreen({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Dashboard'),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.logout),
// //             onPressed: () {
// //               Provider.of<AuthService>(context, listen: false).signOut();
// //             },
// //           ),
// //         ],
// //       ),
// //       body: const Center(child: Text('Welcome to the Dashboard!')),
// //       bottomNavigationBar: BottomNavigationBar(
// //         items: const [
// //           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
// //           BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
// //           BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: 'Finance'),
// //         ],
// //         onTap: (index) {
// //           switch (index) {
// //             case 0:
// //               Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
// //               break;
// //             case 1:
// //               Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatAssistantScreen()));
// //               break;
// //             case 2:
// //               Navigator.push(context, MaterialPageRoute(builder: (_) => const MicrofinanceScreen()));
// //               break;
// //           }
// //         },
// //       ),
// //     );
// //   }
// // }
// // class LoginScreen extends StatelessWidget {
// //   const LoginScreen({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     final authService = Provider.of<AuthService>(context);

// //     return Scaffold(
// //       appBar: AppBar(title: const Text('Login')),
// //       body: Center(
// //         child: ElevatedButton(
// //           onPressed: () async {
// //             await authService.signInWithGoogle();
// //           },
// //           child: const Text('Sign in with Google'),
// //         ),
// //       ),
// //     );
// //   }
// // }
// // class ChatAssistantScreen extends StatelessWidget {
// //   const ChatAssistantScreen({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('Chat Assistant')),
// //       body: const Center(child: Text('Chat Assistant Screen')),
// //     );
// //   }
// // }
// // class MicrofinanceScreen extends StatelessWidget {
// //   const MicrofinanceScreen({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('Microfinance')),
// //       body: const Center(child: Text('Microfinance Screen')),
// //     );
// //   }
// // }

// import 'package:finlink/firebase_options.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/services.dart';

// // Core providers
// import 'providers/auth_provider.dart';
// import 'providers/wallet_provider.dart';
// import 'providers/ai_provider.dart';
// import 'providers/transaction_provider.dart';

// // Screens
// import 'screens/onboarding_screen.dart';
// import 'screens/home_screen.dart';
// import 'screens/splash_screen.dart';

// // Services
// import 'services/firebase_service.dart';
// import 'services/ai_service.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
  
//   // Initialize services
//   await FirebaseService.initialize();
//   await AIService.initialize();
  
//   runApp(FinLinkApp());
// }

// class FinLinkApp extends StatelessWidget {
//   const FinLinkApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
//         ChangeNotifierProvider(create: (_) => WalletProvider()),
//         ChangeNotifierProvider(create: (_) => AIProvider()),
//         ChangeNotifierProvider(create: (_) => TransactionProvider()),
//       ],
//       child: MaterialApp(
//         title: 'FinLink - Inclusión Financiera',
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//           primaryColor: Color(0xFF2E7D32),
//           colorScheme: ColorScheme.fromSeed(
//             seedColor: Color(0xFF2E7D32),
//             brightness: Brightness.light,
//           ),
//           useMaterial3: true,
//           fontFamily: 'Roboto',
//           appBarTheme: AppBarTheme(
//             elevation: 0,
//             centerTitle: true,
//             backgroundColor: Colors.transparent,
//             foregroundColor: Color(0xFF2E7D32),
//             systemOverlayStyle: SystemUiOverlayStyle.dark,
//           ),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Color(0xFF2E7D32),
//               foregroundColor: Colors.white,
//               elevation: 2,
//               padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           ),
//           cardTheme: CardThemeData(
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//           ),
//         ),
//         home: AuthWrapper(),
//         routes: {
//           '/onboarding': (context) => OnboardingScreen(),
//           '/home': (context) => HomeScreen(),
//         },
//       ),
//     );
//   }
// }

// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return SplashScreen();
//         }
        
//         if (snapshot.hasData) {
//           return HomeScreen();
//         }
        
//         return OnboardingScreen();
//       },
//     );
//   }
// }

// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Services
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/spei_service.dart';
import 'services/notification_service.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/account_provider.dart';
import 'providers/transfer_provider.dart';
import 'providers/theme_provider.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/accounts/accounts_screen.dart';
import 'screens/transfers/transfer_screen.dart';
import 'screens/transfers/transfer_history_screen.dart';
import 'screens/profile/profile_screen.dart';

// Utils
import 'utils/app_theme.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await _initializeServices();
  
  runApp(const FinLinkApp());
}

Future<void> _initializeServices() async {
  // Initialize SharedPreferences
  await SharedPreferences.getInstance();
  
  // Initialize notifications
  await NotificationService.initialize();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
}

class FinLinkApp extends StatelessWidget {
  const FinLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        Provider<AuthService>(create: (context) => AuthService(context.read<ApiService>())),
        Provider<SPEIService>(create: (context) => SPEIService(context.read<ApiService>())),
        
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(context.read<AuthService>()),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AccountProvider>(
          create: (context) => AccountProvider(context.read<ApiService>()),
          update: (context, auth, previous) => 
            previous?..updateAuth(auth) ?? AccountProvider(context.read<ApiService>())..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, TransferProvider>(
          create: (context) => TransferProvider(context.read<SPEIService>()),
          update: (context, auth, previous) => 
            previous?..updateAuth(auth) ?? TransferProvider(context.read<SPEIService>())..updateAuth(auth),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'FinLink SPEI+',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('es', 'MX'), // Spanish (Mexico)
              Locale('en', 'US'), // English (US)
            ],
            locale: const Locale('es', 'MX'),
            debugShowCheckedModeBanner: false,
            home: const AuthWrapper(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const HomeScreen(),
              '/accounts': (context) => const AccountsScreen(),
              '/transfer': (context) => const TransferScreen(),
              '/transfer-history': (context) => const TransferHistoryScreen(),
              '/profile': (context) => const ProfileScreen(),
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const SplashScreen();
        }
        
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        }
        
        return const LoginScreen();
      },
    );
  }
}