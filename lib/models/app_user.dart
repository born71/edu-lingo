/// User model for authentication
class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool emailVerified;
  final DateTime? createdAt;
  final AuthProvider provider;

  const AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.emailVerified = false,
    this.createdAt,
    this.provider = AuthProvider.email,
  });

  factory AppUser.fromFirebaseUser(dynamic firebaseUser) {
    return AppUser(
      uid: firebaseUser.uid ?? '',
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      emailVerified: firebaseUser.emailVerified ?? false,
      createdAt: firebaseUser.metadata?.creationTime,
      provider: _determineProvider(firebaseUser),
    );
  }

  static AuthProvider _determineProvider(dynamic firebaseUser) {
    if (firebaseUser.providerData != null) {
      for (var provider in firebaseUser.providerData) {
        if (provider.providerId == 'google.com') return AuthProvider.google;
        if (provider.providerId == 'facebook.com') return AuthProvider.facebook;
        if (provider.providerId == 'apple.com') return AuthProvider.apple;
      }
    }
    return AuthProvider.email;
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'emailVerified': emailVerified,
      'createdAt': createdAt?.toIso8601String(),
      'provider': provider.name,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      emailVerified: json['emailVerified'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      provider: AuthProvider.values.firstWhere(
        (e) => e.name == json['provider'],
        orElse: () => AuthProvider.email,
      ),
    );
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? emailVerified,
    DateTime? createdAt,
    AuthProvider? provider,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      provider: provider ?? this.provider,
    );
  }
}

/// Authentication providers
enum AuthProvider {
  email,
  google,
  facebook,
  apple,
}

/// Authentication result wrapper
class AuthResult {
  final bool success;
  final AppUser? user;
  final String? errorMessage;
  final AuthErrorCode? errorCode;

  const AuthResult({
    required this.success,
    this.user,
    this.errorMessage,
    this.errorCode,
  });

  factory AuthResult.success(AppUser user) {
    return AuthResult(success: true, user: user);
  }

  factory AuthResult.failure(String message, [AuthErrorCode? code]) {
    return AuthResult(
      success: false,
      errorMessage: message,
      errorCode: code,
    );
  }
}

/// Common authentication error codes
enum AuthErrorCode {
  invalidEmail,
  userDisabled,
  userNotFound,
  wrongPassword,
  emailAlreadyInUse,
  weakPassword,
  operationNotAllowed,
  networkError,
  tooManyRequests,
  unknown,
}
