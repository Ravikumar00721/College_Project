import 'package:go_router/go_router.dart';

// Import Screens
import '../views/auth/login_screen.dart';
import '../views/auth/signup_screen.dart';
import '../views/home/home_screen.dart';
import '../views/profile/profile_screen.dart';
import '../views/splash/splash_screen.dart';
import '../views/tutorial/tutorial_screen.dart';

// 🔹 GoRouter Configuration
final GoRouter router = GoRouter(
  initialLocation: "/", // Start with Splash Screen
  routes: [
    GoRoute(path: "/", builder: (context, state) => SplashScreen()),
    GoRoute(
        path: "/tutorial", builder: (context, state) => WalkthroughScreen()),
    GoRoute(path: "/login", builder: (context, state) => LoginInPage()),
    GoRoute(path: "/signup", builder: (context, state) => SignUpPage()),
    GoRoute(path: "/home", builder: (context, state) => HomeScreen()),
    GoRoute(path: "/myprofile", builder: (context, state) => MyProfileScreen()),
  ],
);
