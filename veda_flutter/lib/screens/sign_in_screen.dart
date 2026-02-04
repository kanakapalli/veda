// Re-export the auth flow screen for backwards compatibility
export 'auth/auth_flow_screen.dart' show AuthFlowScreen;

import 'auth/auth_flow_screen.dart';

/// SignInScreen is now an alias for AuthFlowScreen
typedef SignInScreen = AuthFlowScreen;
