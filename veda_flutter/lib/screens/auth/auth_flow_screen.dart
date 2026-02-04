import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import '../../main.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'otp_screen.dart';
import 'forgot_password_screen.dart';
import 'reset_password_screen.dart';

/// Data collected during registration
class RegistrationData {
  String email = '';
  String password = '';
  String fullName = '';
  String bio = '';
  List<String> interests = [];
  String? learningGoal;
  UuidValue? accountRequestId;
  String? registrationToken;
}

/// Data collected during password reset
class PasswordResetData {
  String email = '';
  UuidValue? passwordResetRequestId;
  String? finishPasswordResetToken;
}

class AuthFlowScreen extends StatefulWidget {
  final Widget child;
  const AuthFlowScreen({super.key, required this.child});

  @override
  State<AuthFlowScreen> createState() => _AuthFlowScreenState();
}

class _AuthFlowScreenState extends State<AuthFlowScreen> {
  bool _isSignedIn = false;
  final RegistrationData _registrationData = RegistrationData();
  final PasswordResetData _passwordResetData = PasswordResetData();
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    client.auth.authInfoListenable.addListener(_updateSignedInState);
    _isSignedIn = client.auth.isAuthenticated;
  }

  @override
  void dispose() {
    client.auth.authInfoListenable.removeListener(_updateSignedInState);
    super.dispose();
  }

  void _updateSignedInState() {
    setState(() {
      _isSignedIn = client.auth.isAuthenticated;
    });
  }

  void _pushScreen(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _popToLogin({String? successMessage}) {
    _successMessage = successMessage;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    if (_isSignedIn) return widget.child;

    return LoginScreen(
      onLogin: () {
        // Login successful, state will update via listener
      },
      onCreateAccount: () {
        _pushScreen(
          RegisterScreen(
            registrationData: _registrationData,
            onOtpSent: () {
              _pushScreen(
                OtpScreen(
                  mode: OtpMode.registration,
                  registrationData: _registrationData,
                  onVerified: () {
                    // Registration complete, state will update via listener
                    // Pop all screens back
                    _popToLogin();
                  },
                  onBack: () => Navigator.of(context).pop(),
                  setError: (_) {},
                ),
              );
            },
            onBack: () => Navigator.of(context).pop(),
            setError: (_) {},
          ),
        );
      },
      onForgotPassword: () {
        _pushScreen(
          ForgotPasswordScreen(
            passwordResetData: _passwordResetData,
            onOtpSent: () {
              _pushScreen(
                OtpScreen(
                  mode: OtpMode.passwordReset,
                  passwordResetData: _passwordResetData,
                  onVerified: () {
                    _pushScreen(
                      ResetPasswordScreen(
                        passwordResetData: _passwordResetData,
                        onPasswordReset: () {
                          _popToLogin(
                            successMessage:
                                'Password reset successful. Please sign in.',
                          );
                        },
                        onBack: () => _popToLogin(),
                        setError: (_) {},
                      ),
                    );
                  },
                  onBack: () => Navigator.of(context).pop(),
                  setError: (_) {},
                ),
              );
            },
            onBack: () => Navigator.of(context).pop(),
            setError: (_) {},
          ),
        );
      },
      successMessage: _successMessage,
      setError: (_) {},
    );
  }
}
