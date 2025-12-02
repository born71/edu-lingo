import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

/// Firebase Authentication Service
/// Handles email/password authentication and prepares for SSO providers
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current AppUser
  AppUser? get currentAppUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return AppUser.fromFirebaseUser(user);
  }

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // ===== ACCESS TOKEN METHODS =====

  /// Get Firebase ID token (JWT)
  /// This token can be used to authenticate with your backend API
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      
      return await user.getIdToken(forceRefresh);
    } catch (e) {
      print('Error getting ID token: $e');
      return null;
    }
  }

  /// Get ID token result with additional claims
  Future<IdTokenResult?> getIdTokenResult({bool forceRefresh = false}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      
      return await user.getIdTokenResult(forceRefresh);
    } catch (e) {
      print('Error getting ID token result: $e');
      return null;
    }
  }

  /// Check if the current token is expired and refresh if needed
  Future<String?> getFreshIdToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final tokenResult = await user.getIdTokenResult(false);
      final now = DateTime.now();
      final expirationTime = tokenResult.expirationTime;

      // If token expires within 5 minutes, refresh it
      if (expirationTime != null && 
          expirationTime.difference(now).inMinutes < 5) {
        return await user.getIdToken(true); // Force refresh
      }
      
      return tokenResult.token;
    } catch (e) {
      print('Error getting fresh ID token: $e');
      return null;
    }
  }

  /// Get authorization headers for API calls
  Future<Map<String, String>?> getAuthHeaders() async {
    final token = await getFreshIdToken();
    if (token == null) return null;
    
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // ===== EMAIL/PASSWORD AUTHENTICATION =====

  /// Sign up with email and password
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName);
        await credential.user?.reload();
      }

      // Send email verification
      await credential.user?.sendEmailVerification();

      final user = _auth.currentUser;
      if (user != null) {
        return AuthResult.success(AppUser.fromFirebaseUser(user));
      }

      return AuthResult.failure('Failed to create account');
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthError(e);
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred: $e');
    }
  }

  /// Sign in with email and password
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        return AuthResult.success(AppUser.fromFirebaseUser(user));
      }

      return AuthResult.failure('Failed to sign in');
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthError(e);
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred: $e');
    }
  }

  /// Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return const AuthResult(
        success: true,
        errorMessage: 'Password reset email sent',
      );
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthError(e);
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred: $e');
    }
  }

  /// Resend email verification
  Future<AuthResult> resendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return const AuthResult(
          success: true,
          errorMessage: 'Verification email sent',
        );
      }
      return AuthResult.failure('No user logged in or email already verified');
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthError(e);
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred: $e');
    }
  }

  // ===== SSO AUTHENTICATION (Prepared for future implementation) =====

  /// Sign in with Google
  /// TODO: Implement when google_sign_in package is added
  Future<AuthResult> signInWithGoogle() async {
    // Placeholder for Google Sign-In implementation
    // Required packages: google_sign_in, firebase_auth
    /*
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return AuthResult.failure('Google sign-in cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user != null) {
        return AuthResult.success(AppUser.fromFirebaseUser(user));
      }
      return AuthResult.failure('Failed to sign in with Google');
    } catch (e) {
      return AuthResult.failure('Google sign-in failed: $e');
    }
    */
    return AuthResult.failure(
      'Google Sign-In not yet implemented',
      AuthErrorCode.operationNotAllowed,
    );
  }

  /// Sign in with Facebook
  /// TODO: Implement when flutter_facebook_auth package is added
  Future<AuthResult> signInWithFacebook() async {
    // Placeholder for Facebook Sign-In implementation
    // Required packages: flutter_facebook_auth, firebase_auth
    /*
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();
      if (loginResult.status != LoginStatus.success) {
        return AuthResult.failure('Facebook sign-in cancelled');
      }

      final OAuthCredential credential = FacebookAuthProvider.credential(
        loginResult.accessToken!.token,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user != null) {
        return AuthResult.success(AppUser.fromFirebaseUser(user));
      }
      return AuthResult.failure('Failed to sign in with Facebook');
    } catch (e) {
      return AuthResult.failure('Facebook sign-in failed: $e');
    }
    */
    return AuthResult.failure(
      'Facebook Sign-In not yet implemented',
      AuthErrorCode.operationNotAllowed,
    );
  }

  /// Sign in with Apple
  /// TODO: Implement when sign_in_with_apple package is added
  Future<AuthResult> signInWithApple() async {
    // Placeholder for Apple Sign-In implementation
    // Required packages: sign_in_with_apple, firebase_auth
    /*
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);
      final user = userCredential.user;
      
      if (user != null) {
        return AuthResult.success(AppUser.fromFirebaseUser(user));
      }
      return AuthResult.failure('Failed to sign in with Apple');
    } catch (e) {
      return AuthResult.failure('Apple sign-in failed: $e');
    }
    */
    return AuthResult.failure(
      'Apple Sign-In not yet implemented',
      AuthErrorCode.operationNotAllowed,
    );
  }

  // ===== ACCOUNT MANAGEMENT =====

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    // TODO: Sign out from SSO providers when implemented
    // await GoogleSignIn().signOut();
    // await FacebookAuth.instance.logOut();
  }

  /// Update user profile
  Future<AuthResult> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('No user logged in');
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      await user.reload();
      return AuthResult.success(AppUser.fromFirebaseUser(_auth.currentUser!));
    } catch (e) {
      return AuthResult.failure('Failed to update profile: $e');
    }
  }

  /// Update email
  Future<AuthResult> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('No user logged in');
      }

      await user.verifyBeforeUpdateEmail(newEmail);
      return const AuthResult(
        success: true,
        errorMessage: 'Verification email sent to new address',
      );
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthError(e);
    } catch (e) {
      return AuthResult.failure('Failed to update email: $e');
    }
  }

  /// Update password
  Future<AuthResult> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('No user logged in');
      }

      await user.updatePassword(newPassword);
      return const AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthError(e);
    } catch (e) {
      return AuthResult.failure('Failed to update password: $e');
    }
  }

  /// Delete account
  Future<AuthResult> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('No user logged in');
      }

      await user.delete();
      return const AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthError(e);
    } catch (e) {
      return AuthResult.failure('Failed to delete account: $e');
    }
  }

  /// Re-authenticate user (required before sensitive operations)
  Future<AuthResult> reauthenticate(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        return AuthResult.failure('No user logged in');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      return const AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthError(e);
    } catch (e) {
      return AuthResult.failure('Re-authentication failed: $e');
    }
  }

  // ===== ERROR HANDLING =====

  AuthResult _handleFirebaseAuthError(FirebaseAuthException e) {
    String message;
    AuthErrorCode code;

    switch (e.code) {
      case 'invalid-email':
        message = 'The email address is invalid.';
        code = AuthErrorCode.invalidEmail;
        break;
      case 'user-disabled':
        message = 'This account has been disabled.';
        code = AuthErrorCode.userDisabled;
        break;
      case 'user-not-found':
        message = 'No account found with this email.';
        code = AuthErrorCode.userNotFound;
        break;
      case 'wrong-password':
        message = 'Incorrect password.';
        code = AuthErrorCode.wrongPassword;
        break;
      case 'email-already-in-use':
        message = 'An account already exists with this email.';
        code = AuthErrorCode.emailAlreadyInUse;
        break;
      case 'weak-password':
        message = 'Password should be at least 6 characters.';
        code = AuthErrorCode.weakPassword;
        break;
      case 'operation-not-allowed':
        message = 'This sign-in method is not enabled.';
        code = AuthErrorCode.operationNotAllowed;
        break;
      case 'network-request-failed':
        message = 'Network error. Please check your connection.';
        code = AuthErrorCode.networkError;
        break;
      case 'too-many-requests':
        message = 'Too many attempts. Please try again later.';
        code = AuthErrorCode.tooManyRequests;
        break;
      case 'invalid-credential':
        message = 'Invalid email or password.';
        code = AuthErrorCode.wrongPassword;
        break;
      default:
        message = e.message ?? 'An authentication error occurred.';
        code = AuthErrorCode.unknown;
    }

    return AuthResult.failure(message, code);
  }
}
