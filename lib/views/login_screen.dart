// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input_field.dart';
import 'dashboard_screen.dart';

// Login Screen - View layer for authentication
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin(BuildContext context, LoginViewModel viewModel) async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Perform login
    await viewModel.login();

    // Check if login was successful
    if (viewModel.isLoggedIn && mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful! Welcome back.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate to dashboard after a brief delay
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } else if (viewModel.loginResponse.hasError && mounted) {
      // Show error message - clean up nested exception messages
      String errorMessage = viewModel.loginResponse.error ?? 'Login failed';
      // Remove nested "Exception: " prefixes
      while (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      // Remove "Network error: " prefix if present
      if (errorMessage.startsWith('Network error: ')) {
        errorMessage = errorMessage.substring(15);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<LoginViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),

                  // App Logo/Title
                  Icon(
                    Icons.lock_outline,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Sign in to continue',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Email Input
                  CustomInputField(
                    label: 'Email',
                    hint: 'Enter your email',
                    controller: _emailController,
                    onChanged: viewModel.setEmail,
                    errorText: viewModel.emailError,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 20),

                  // Password Input
                  CustomInputField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _passwordController,
                    onChanged: viewModel.setPassword,
                    errorText: viewModel.passwordError,
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outlined,
                    suffixIcon: _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    onSuffixIconTap: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  const SizedBox(height: 32),

                  // Login Button
                  CustomButton(
                    text: 'Login',
                    isLoading: viewModel.isLoading,
                    onPressed: () => _handleLogin(context, viewModel),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
