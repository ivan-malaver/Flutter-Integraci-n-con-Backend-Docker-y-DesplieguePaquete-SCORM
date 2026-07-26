import 'package:flutter/material.dart';
import 'package:eco_home_app/screens/login_screen.dart';
import 'package:eco_home_app/screens/catalog_screen.dart';
import 'package:eco_home_app/services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoHome Store',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  String? token;
  String? username;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    final t = await AuthService.getToken();
    final u = await AuthService.getUsername();
    setState(() {
      token = t;
      username = u;
      isLoading = false;
    });
  }

  void onLoginSuccess(String t, String u) {
    setState(() {
      token = t;
      username = u;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (token != null && username != null) {
      return CatalogScreen(token: token!, username: username!);
    } else {
      return LoginScreen(onLoginSuccess: onLoginSuccess);
    }
  }
}