import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.init();

      if (!mounted) return;

      if (authService.token != null) {
        print('Token exists, navigating to home');
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        print('No token found, navigating to login');
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      print('Error in _checkAuth: $e');
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Error initializing app: $e',
          toastLength: Toast.LENGTH_LONG,
        );
        // Navigate to login as fallback
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/images/img.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 24),
            const Text(
              'Celeb',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'Rate',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
