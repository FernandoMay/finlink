// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'services/auth_service.dart';
// import 'services/gemini_service.dart';
// import 'providers/finance_provider.dart';
// import 'screens/dashboard_screen.dart';
// import 'screens/login_screen.dart';
// import 'screens/chat_assistant_screen.dart';
// import 'screens/microfinance_screen.dart';

// void main() {
//   runApp(const FinLinkApp());
// }

// class FinLinkApp extends StatelessWidget {
//   const FinLinkApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         Provider<AuthService>(create: (_) => AuthService()),
//         Provider<GeminiService>(create: (_) => GeminiService()),
//         ChangeNotifierProvider(create: (_) => FinanceProvider()),
//       ],
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'FinLink',
//         theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
//           useMaterial3: true,
//         ),
//         home: const AuthWrapper(),
//       ),
//     );
//   }
// }

// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authService = Provider.of<AuthService>(context);

//     return StreamBuilder(
//       stream: authService.authStateChanges,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }
//         if (snapshot.hasData) {
//           return const DashboardScreen();
//         } else {
//           return const LoginScreen();
//         }
//       },
//     );
//   }
// }
// class DashboardScreen extends StatelessWidget {
//   const DashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Dashboard'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () {
//               Provider.of<AuthService>(context, listen: false).signOut();
//             },
//           ),
//         ],
//       ),
//       body: const Center(child: Text('Welcome to the Dashboard!')),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
//           BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: 'Finance'),
//         ],
//         onTap: (index) {
//           switch (index) {
//             case 0:
//               Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
//               break;
//             case 1:
//               Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatAssistantScreen()));
//               break;
//             case 2:
//               Navigator.push(context, MaterialPageRoute(builder: (_) => const MicrofinanceScreen()));
//               break;
//           }
//         },
//       ),
//     );
//   }
// }
// class LoginScreen extends StatelessWidget {
//   const LoginScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authService = Provider.of<AuthService>(context);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Login')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () async {
//             await authService.signInWithGoogle();
//           },
//           child: const Text('Sign in with Google'),
//         ),
//       ),
//     );
//   }
// }
// class ChatAssistantScreen extends StatelessWidget {
//   const ChatAssistantScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Chat Assistant')),
//       body: const Center(child: Text('Chat Assistant Screen')),
//     );
//   }
// }
// class MicrofinanceScreen extends StatelessWidget {
//   const MicrofinanceScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Microfinance')),
//       body: const Center(child: Text('Microfinance Screen')),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

// Core providers
import 'providers/auth_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/ai_provider.dart';
import 'providers/transaction_provider.dart';

// Screens
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

// Services
import 'services/firebase_service.dart';
import 'services/ai_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize services
  await FirebaseService.initialize();
  await AIService.initialize();
  
  runApp(FinLinkApp());
}

class FinLinkApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => AIProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: 'FinLink - Inclusión Financiera',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Color(0xFF2E7D32),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(0xFF2E7D32),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          appBarTheme: AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            foregroundColor: Color(0xFF2E7D32),
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              elevation: 2,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          cardTheme: CardTheme(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        home: AuthWrapper(),
        routes: {
          '/onboarding': (context) => OnboardingScreen(),
          '/home': (context) => HomeScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen();
        }
        
        if (snapshot.hasData) {
          return HomeScreen();
        }
        
        return OnboardingScreen();
      },
    );
  }
}