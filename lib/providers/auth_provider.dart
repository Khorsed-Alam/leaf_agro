import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/user_profile_model.dart';
import '../core/errors/app_exceptions.dart';

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
  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  Future<AuthState> build() async {
    return await _resolveCurrentSession();
  }

  Future<AuthState> _resolveCurrentSession() async {
    final session = _supabase.auth.currentSession;
    if (session == null) {
      return const AuthState(status: AuthStatus.unauthenticated);
    }
    try {
      final profileData = await _supabase
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
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (response.user == null) {
        throw const AuthException('Sign in failed: no user returned.');
      }
      final profileData = await _supabase
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
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      state = AsyncValue.data(
        AuthState(
          status: AuthStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> signUp(String email, String password, String fullName) async {
    state = const AsyncValue.data(AuthState(status: AuthStatus.loading));
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName},
      );
      if (response.user == null) {
        throw const AuthException('Sign up failed: no user returned.');
      }
      // Insert profile row
      final now = DateTime.now();
      final profile = UserProfileModel(
        id: response.user!.id,
        fullName: fullName,
        preferredLanguage: 'en',
        createdAt: now,
      );
      await _supabase.from('profiles').upsert(profile.toJson());
      state = AsyncValue.data(
        AuthState(status: AuthStatus.authenticated, user: profile),
      );
    } on AuthException catch (e) {
      state = AsyncValue.data(
        AuthState(status: AuthStatus.error, errorMessage: e.message),
      );
    } catch (e) {
      state = AsyncValue.data(
        AuthState(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> signInWithEmail(String email, String password) =>
      signIn(email, password);

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) =>
      signUp(email, password, fullName);

  Future<void> signOut() async {
    state = const AsyncValue.data(AuthState(status: AuthStatus.loading));
    try {
      await _supabase.auth.signOut();
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
