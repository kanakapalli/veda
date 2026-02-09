import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import '../../../main.dart';
import 'web_creator_login_screen.dart';
import 'web_creator_register_screen.dart';
import 'web_creator_otp_screen.dart';

/// Web Creator Authentication Flow
/// Manages login/register/OTP flow for course creators
class WebCreatorAuthFlow extends StatefulWidget {
  final Widget child;

  const WebCreatorAuthFlow({super.key, required this.child});

  @override
  State<WebCreatorAuthFlow> createState() => _WebCreatorAuthFlowState();
}

class _WebCreatorAuthFlowState extends State<WebCreatorAuthFlow> {
  bool _isSignedIn = false;
  bool _showRegister = false;
  bool _showOtp = false;
  final CreatorRegistrationData _registrationData = CreatorRegistrationData();

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

  void _switchToRegister() {
    setState(() {
      _showRegister = true;
      _showOtp = false;
    });
  }

  void _switchToLogin() {
    setState(() {
      _showRegister = false;
      _showOtp = false;
    });
  }

  void _showOtpScreen() {
    setState(() {
      _showOtp = true;
    });
  }

  void _backFromOtp() {
    setState(() {
      _showOtp = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // If signed in, show the child (course creation)
    if (_isSignedIn) {
      return widget.child;
    }

    // Show OTP screen
    if (_showOtp) {
      return WebCreatorOtpScreen(
        registrationData: _registrationData,
        onVerified: () {
          // After successful verification, state will update via listener
        },
        onBack: _backFromOtp,
      );
    }

    // Show register screen
    if (_showRegister) {
      return WebCreatorRegisterScreen(
        registrationData: _registrationData,
        onOtpSent: _showOtpScreen,
        onSwitchToLogin: _switchToLogin,
      );
    }

    // Show login screen (default)
    return WebCreatorLoginScreen(
      onLoginSuccess: () {
        // After successful login, state will update via listener
      },
      onSwitchToRegister: _switchToRegister,
    );
  }
}
