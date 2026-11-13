import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  try {
    return AuthService(Supabase.instance.client);
  } catch (_) {
    return AuthService();
  }
});

class AuthService {
  final SupabaseClient? _clientOverride;

  AuthService([SupabaseClient? client]) : _clientOverride = client;

  SupabaseClient get _client => _clientOverride ?? SupabaseConfig.client;

  User? get currentUser {
    try {
      return _client.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  Session? get currentSession {
    try {
      return _client.auth.currentSession;
    } catch (_) {
      return null;
    }
  }

  Stream<AuthState> get authStateChanges {
    try {
      return _client.auth.onAuthStateChange;
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Register a new user with email, password, full name, and phone number
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    bool termsAccepted = true,
  }) async {
    return await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'full_name': fullName.trim(),
        if (phoneNumber != null && phoneNumber.isNotEmpty)
          'phone_number': phoneNumber.trim(),
        'terms_accepted_at': termsAccepted ? DateTime.now().toIso8601String() : null,
      },
    );
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Sign in using Google OAuth
  Future<bool> signInWithGoogle() async {
    return await _client.auth.signInWithOAuth(OAuthProvider.google);
  }

  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email.trim());
  }

  /// Send password recovery email with normalization, validation, and error handling
  Future<PasswordResetResult> sendPasswordResetEmail(
    String email, {
    String? redirectTo,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      return const PasswordResetResult.failure('Email address cannot be empty.');
    }
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(normalizedEmail)) {
      return const PasswordResetResult.failure('Please enter a valid email address.');
    }

    try {
      await _client.auth.resetPasswordForEmail(
        normalizedEmail,
        redirectTo: redirectTo ?? 'agricareai://reset-password',
      );
      return const PasswordResetResult.success();
    } on AuthException catch (e) {
      return PasswordResetResult.failure(e.message);
    } catch (e) {
      return PasswordResetResult.failure('Connection failed: ${e.toString()}');
    }
  }

  /// Update password for the current user
  Future<UserResponse> updatePassword(String newPassword) async {
    return await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }
}

class PasswordResetResult {
  final bool isSuccess;
  final String? errorMessage;

  const PasswordResetResult.success()
      : isSuccess = true,
        errorMessage = null;

  const PasswordResetResult.failure(this.errorMessage) : isSuccess = false;
}

