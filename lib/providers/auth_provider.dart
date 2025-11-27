import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

/// Authentication state
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Authentication Provider for state management
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthState _state = AuthState.initial;
  AppUser? _user;
  String? _errorMessage;

  // Getters
  AuthState get state => _state;
  AppUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;

  AuthProvider() {
    _init();
  }

  /// Initialize and listen to auth state changes
  void _init() {
    _authService.authStateChanges.listen((User? firebaseUser) {
      if (firebaseUser != null) {
        _user = AppUser.fromFirebaseUser(firebaseUser);
        _state = AuthState.authenticated;
      } else {
        _user = null;
        _state = AuthState.unauthenticated;
      }
      notifyListeners();
    });
  }

  /// Check current auth state
  Future<void> checkAuthState() async {
    _state = AuthState.loading;
    notifyListeners();

    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      _user = AppUser.fromFirebaseUser(currentUser);
      _state = AuthState.authenticated;
    } else {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  // ===== EMAIL/PASSWORD AUTHENTICATION =====

  /// Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _setLoading();

    final result = await _authService.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );

    if (result.success && result.user != null) {
      _user = result.user;
      _state = AuthState.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _setError(result.errorMessage ?? 'Sign up failed');
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading();

    final result = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    if (result.success && result.user != null) {
      _user = result.user;
      _state = AuthState.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _setError(result.errorMessage ?? 'Sign in failed');
      return false;
    }
  }

  /// Send password reset email
  Future<bool> resetPassword(String email) async {
    _setLoading();

    final result = await _authService.sendPasswordResetEmail(email);

    _state = AuthState.unauthenticated;
    if (result.success) {
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _setError(result.errorMessage ?? 'Failed to send reset email');
      return false;
    }
  }

  // ===== SSO AUTHENTICATION =====

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading();

    final result = await _authService.signInWithGoogle();

    if (result.success && result.user != null) {
      _user = result.user;
      _state = AuthState.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _setError(result.errorMessage ?? 'Google sign in failed');
      return false;
    }
  }

  /// Sign in with Facebook
  Future<bool> signInWithFacebook() async {
    _setLoading();

    final result = await _authService.signInWithFacebook();

    if (result.success && result.user != null) {
      _user = result.user;
      _state = AuthState.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _setError(result.errorMessage ?? 'Facebook sign in failed');
      return false;
    }
  }

  /// Sign in with Apple
  Future<bool> signInWithApple() async {
    _setLoading();

    final result = await _authService.signInWithApple();

    if (result.success && result.user != null) {
      _user = result.user;
      _state = AuthState.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _setError(result.errorMessage ?? 'Apple sign in failed');
      return false;
    }
  }

  // ===== ACCOUNT MANAGEMENT =====

  /// Sign out
  Future<void> signOut() async {
    _setLoading();
    await _authService.signOut();
    _user = null;
    _state = AuthState.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  /// Update profile
  Future<bool> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    final result = await _authService.updateProfile(
      displayName: displayName,
      photoUrl: photoUrl,
    );

    if (result.success && result.user != null) {
      _user = result.user;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Resend email verification
  Future<bool> resendVerificationEmail() async {
    final result = await _authService.resendEmailVerification();
    return result.success;
  }

  // ===== HELPER METHODS =====

  void _setLoading() {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _state = AuthState.error;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = _user != null ? AuthState.authenticated : AuthState.unauthenticated;
    }
    notifyListeners();
  }
}
