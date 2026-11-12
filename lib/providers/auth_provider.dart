import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/user_profile_model.dart';

// ── Enums ─────────────────────────────────────────────────────────────────────

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

// ── State ─────────────────────────────────────────────────────────────────────

class AuthState {
  final AuthStatus status;
  final UserProfileModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserProfileModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;

  @override
  String toString() =>
      'AuthState(status: $status, user: ${user?.id}, errorMessage: $errorMessage)';
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class AuthNotifier extends AsyncNotifier<AuthState> {
  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthState> build() async {
    return await _resolveCurrentSession();
  }

  Future<AuthState> _resolveCurrentSession() async {
    final client = _supabase;
    if (client == null) {
      return const AuthState(status: AuthStatus.unauthenticated);
    }
    final session = client.auth.currentSession;
    if (session == null) {
      return const AuthState(status: AuthStatus.unauthenticated);
    }
    try {
      final profileData = await client
          .from('profiles')
          .select()
          .eq('id', session.user.id)
          .maybeSingle();
      if (profileData == null) {
        return const AuthState(status: AuthStatus.unauthenticated);
      }
      final profile = UserProfileModel.fromJson(profileData);
      return AuthState(status: AuthStatus.authenticated, user: profile);
    } catch (_) {
      return const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.data(AuthState(status: AuthStatus.loading));
    try {
      final client = _supabase;
      if (client == null) {
        throw const AuthException('Backend service is currently unavailable.');
      }
      final response = await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (response.user == null) {
        throw const AuthException('Sign in failed: no user returned.');
      }
      final profileData = await client
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();
      final profile =
          profileData != null ? UserProfileModel.fromJson(profileData) : null;
      state = AsyncValue.data(
        AuthState(status: AuthStatus.authenticated, user: profile),
      );
    } on AuthException catch (e) {
      state = AsyncValue.data(
        AuthState(
          status: AuthStatus.error,
          errorMessage: _cleanErrorMessage(e),
        ),
      );
    } catch (e) {
      state = AsyncValue.data(
        AuthState(
          status: AuthStatus.error,
          errorMessage: _cleanErrorMessage(e),
        ),
      );
    }
  }

  static String _cleanErrorMessage(dynamic error) {
    if (error is AuthException) {
      return error.message;
    }
    final message = error.toString();
    if (message.contains('Failed to fetch') ||
        message.contains('SocketException') ||
        message.contains('ClientException') ||
        message.contains('NetworkImage')) {
      return 'Unable to reach the server. Please check your internet connection.';
    }
    return message;
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    bool termsAccepted = true,
  }) async {
    state = const AsyncValue.data(AuthState(status: AuthStatus.loading));
    try {
      final client = _supabase;
      if (client == null) {
        throw const AuthException('Backend service is currently unavailable.');
      }
      final response = await client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': fullName.trim(),
          if (phoneNumber != null && phoneNumber.isNotEmpty)
            'phone_number': phoneNumber.trim(),
          'terms_accepted_at':
              termsAccepted ? DateTime.now().toIso8601String() : null,
        },
      );
      if (response.user == null) {
        throw const AuthException('Sign up failed: no user returned.');
      }
      // Upsert profile row (ensures client-side fallback if DB trigger is pending)
      final now = DateTime.now();
      final profile = UserProfileModel(
        id: response.user!.id,
        fullName: fullName.trim(),
        email: email.trim(),
        phoneNumber: phoneNumber?.trim(),
        preferredLanguage: 'en',
        role: 'farmer',
        termsAcceptedAt: termsAccepted ? now : null,
        createdAt: now,
      );
      try {
        await client.from('profiles').upsert(profile.toJson());
      } catch (_) {
        // Handled gracefully if DB trigger already created profile
      }
      state = AsyncValue.data(
        AuthState(status: AuthStatus.authenticated, user: profile),
      );
    } on AuthException catch (e) {
      state = AsyncValue.data(
        AuthState(status: AuthStatus.error, errorMessage: _cleanErrorMessage(e)),
      );
    } catch (e) {
      state = AsyncValue.data(
        AuthState(status: AuthStatus.error, errorMessage: _cleanErrorMessage(e)),
      );
    }
  }

  Future<void> signInWithEmail(String email, String password) =>
      signIn(email, password);

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.data(AuthState(status: AuthStatus.loading));
    try {
      final client = _supabase;
      if (client == null) {
        throw const AuthException('Backend service is currently unavailable.');
      }
      await client.auth.signInWithOAuth(OAuthProvider.google);
      final newState = await _resolveCurrentSession();
      state = AsyncValue.data(newState);
    } on AuthException catch (e) {
      state = AsyncValue.data(
        AuthState(status: AuthStatus.error, errorMessage: _cleanErrorMessage(e)),
      );
    } catch (e) {
      state = AsyncValue.data(
        AuthState(status: AuthStatus.error, errorMessage: _cleanErrorMessage(e)),
      );
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    bool termsAccepted = true,
  }) =>
      signUp(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        termsAccepted: termsAccepted,
      );

  Future<void> signOut() async {
    state = const AsyncValue.data(AuthState(status: AuthStatus.loading));
    try {
      final client = _supabase;
      if (client != null) {
        await client.auth.signOut();
      }
      state = const AsyncValue.data(
        AuthState(status: AuthStatus.unauthenticated),
      );
    } catch (e) {
      state = AsyncValue.data(
        AuthState(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> checkAuthStatus() async {
    state = const AsyncValue.loading();
    final newState = await _resolveCurrentSession();
    state = AsyncValue.data(newState);
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final authProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

final currentUserProvider = Provider<UserProfileModel?>((ref) {
  return ref.watch(authProvider).value?.user;
});
