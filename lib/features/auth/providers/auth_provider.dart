import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthState {
  final bool isAuthenticated;
  final String? userId;
  final String? email;
  final String? displayName;

  AuthState({
    this.isAuthenticated = false,
    this.userId,
    this.email,
    this.displayName,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? email,
    String? displayName,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final isAuthenticated = prefs.getBool('is_authenticated') ?? false;
    final userId = prefs.getString('user_id');
    final email = prefs.getString('email');
    final displayName = prefs.getString('display_name');

    state = AuthState(
      isAuthenticated: isAuthenticated,
      userId: userId,
      email: email,
      displayName: displayName,
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    // Simple local authentication - in production, use proper password hashing
    // For now, just store the email as the user ID
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_authenticated', true);
    await prefs.setString('user_id', email); // Using email as ID for simplicity
    await prefs.setString('email', email);
    await prefs.setString('display_name', email.split('@')[0]);

    state = AuthState(
      isAuthenticated: true,
      userId: email,
      email: email,
      displayName: email.split('@')[0],
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // Simple local registration
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_authenticated', true);
    await prefs.setString('user_id', email);
    await prefs.setString('email', email);
    await prefs.setString('display_name', displayName);

    state = AuthState(
      isAuthenticated: true,
      userId: email,
      email: email,
      displayName: displayName,
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_authenticated', false);
    await prefs.remove('user_id');
    await prefs.remove('email');
    await prefs.remove('display_name');

    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
