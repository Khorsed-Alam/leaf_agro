import 'package:supabase_flutter/supabase_flutter.dart';
import '../datasources/remote/supabase_datasource.dart';
import '../models/user_profile_model.dart';

class AuthRepository {
  final SupabaseDataSource _remoteDataSource;
  AuthRepository(this._remoteDataSource);

  User? get currentUser => _remoteDataSource.currentUser;

  Future<AuthResponse> login(String email, String password) =>
      _remoteDataSource.signIn(email, password);

  Future<AuthResponse> register(String email, String password, {String? fullName}) =>
      _remoteDataSource.signUp(email, password, fullName: fullName);

  Future<void> logout() => _remoteDataSource.signOut();

  Future<UserProfileModel?> getUserProfile(String userId) =>
      _remoteDataSource.getProfile(userId);
}

