import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_craft_ai/services/auth_services.dart';

import '../../widgets/bouncing.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthService authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _isLoading = false;

  void registerUser() async {
    setState(() {
      _isLoading = true;
    });

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter email and password")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    User? user = await authService.signUpWithEmail(email, password);

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Account Created Successfully!")),
      );
      context.go("/login"); // Navigate to Login Screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration Failed")),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void signInWithGoogle() async {
    User? user = await authService.signInWithGoogle();
    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logged in with Google: ${user.email}")),
      );
      context.go("/home");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In Failed")),
      );
    }
  }

  void signInWithApple() async {
    User? user = await AuthService().signInWithApple();
    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logged in with Apple: ${user.email}")),
      );
      context.go("/home");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Apple Sign-In Failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            height: constraints.maxHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDarkMode
                    ? [Colors.blueGrey.shade900, Colors.blueGrey.shade800]
                    : [Colors.blue.shade200, Colors.blue.shade100],
              ),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                Colors.blue.shade400,
                                Colors.blue.shade700
                              ],
                            ).createShader(bounds),
                            child: const Icon(
                              Icons.person_add,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          "Create Account",
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Please sign up to continue",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color:
                                theme.colorScheme.onBackground.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 40),
                        _buildEmailField(theme),
                        const SizedBox(height: 20),
                        _buildPasswordField(theme),
                        const SizedBox(height: 24),
                        _buildSignUpButton(theme),
                        const SizedBox(height: 20),
                        _buildSocialLoginSection(theme),
                        const Spacer(), // pushes login prompt to bottom
                        _buildLoginPrompt(theme),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmailField(ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _emailFocus.hasFocus ? theme.primaryColor : theme.dividerColor,
          width: 2,
        ),
        boxShadow: _emailFocus.hasFocus
            ? [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: emailController,
        focusNode: _emailFocus,
        decoration: InputDecoration(
          filled: true,
          fillColor: theme.cardColor,
          prefixIcon: Icon(Icons.email, color: theme.primaryColor),
          hintText: "Enter your email",
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
        ),
        style: theme.textTheme.bodyLarge,
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }

  Widget _buildPasswordField(ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _passwordFocus.hasFocus ? theme.primaryColor : theme.dividerColor,
          width: 2,
        ),
        boxShadow: _passwordFocus.hasFocus
            ? [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: passwordController,
        focusNode: _passwordFocus,
        obscureText: true,
        decoration: InputDecoration(
          filled: true,
          fillColor: theme.cardColor,
          prefixIcon: Icon(Icons.lock, color: theme.primaryColor),
          hintText: "Enter your password",
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
        ),
        style: theme.textTheme.bodyLarge,
      ),
    );
  }

  Widget _buildSignUpButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade700],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade200.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _isLoading ? null : registerUser,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: _isLoading
                    ? const BouncingDotsLoader(
                        color: Colors.white,
                        dotSize: 12,
                        duration: Duration(milliseconds: 800),
                      )
                    : Text(
                        "SIGN UP",
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginSection(ThemeData theme) {
    return Column(
      children: [
        Text(
          "Or continue with",
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onBackground.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              icon: 'assets/image/google.png',
              onTap: signInWithGoogle,
              color: Colors.white,
            ),
            const SizedBox(width: 20),
            _buildSocialButton(
              icon: 'assets/image/apple.png',
              onTap: signInWithApple,
              color: Colors.black,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Image.asset(
          icon,
          width: 32,
          height: 32,
          color: color == Colors.black ? Colors.white : null,
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onBackground.withOpacity(0.6),
          ),
        ),
        InkWell(
          onTap: () => context.go("/login"),
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade700],
            ).createShader(bounds),
            child: Text(
              "Sign in now",
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
