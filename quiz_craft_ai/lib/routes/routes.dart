import 'package:go_router/go_router.dart';
import 'package:quiz_craft_ai/views/auth/signup_screen.dart';
import 'package:quiz_craft_ai/views/tutorial/tutorial_screen.dart';

import '../views/splash/splash_screen.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: '/walkthroughscreen',
      builder: (context, state) => WalkthroughScreen(), // Next step
    ),
    GoRoute(
      path: '/signin',
      builder: (context, state) => SignInPage(), // Next step
    ),
  ],
);
