/// Pure HTML template generator for transactional emails.
///
/// All templates follow the Veda Neo-Minimalist design system:
/// black background, white text, blue (#4A90E2) accent on the OTP code.
/// Table-based layout with inline CSS for maximum email client compatibility.
class EmailTemplates {
  EmailTemplates._();

  static String registrationVerificationCode({
    required String verificationCode,
    required String recipientEmail,
  }) {
    return _wrapInLayout(
      heading: 'Verify your email',
      bodyContent: 'Enter the following code to complete your '
          'registration for Veda.',
      code: verificationCode,
      footerNote: 'This code expires in 15 minutes. If you did not request '
          'this, you can safely ignore this email.',
      recipientEmail: recipientEmail,
    );
  }

  static String passwordResetVerificationCode({
    required String verificationCode,
    required String recipientEmail,
  }) {
    return _wrapInLayout(
      heading: 'Reset your password',
      bodyContent: 'Enter the following code to reset your password for Veda. '
          'If you did not request a password reset, please ignore this email.',
      code: verificationCode,
      footerNote: 'This code expires in 15 minutes.',
      recipientEmail: recipientEmail,
    );
  }

  static String _wrapInLayout({
    required String heading,
    required String bodyContent,
    required String code,
    required String footerNote,
    required String recipientEmail,
  }) {
    final escapedEmail = _escapeHtml(recipientEmail);
    final escapedCode = _escapeHtml(code);

    return '''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>$heading &mdash; Veda</title>
</head>
<body style="margin:0;padding:0;background-color:#000000;-webkit-text-size-adjust:none;">
<table width="100%" cellpadding="0" cellspacing="0" role="presentation" style="background-color:#000000;">
<tr><td align="center" style="padding:48px 24px;">
<table width="600" cellpadding="0" cellspacing="0" role="presentation" style="max-width:600px;width:100%;">

<!-- Branding -->
<tr><td style="padding-bottom:48px;">
<span style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;font-size:28px;font-weight:300;color:#FFFFFF;letter-spacing:-0.5px;">Veda</span>
</td></tr>

<!-- Accent line -->
<tr><td style="padding-bottom:48px;">
<div style="width:48px;height:1px;background-color:#4A90E2;"></div>
</td></tr>

<!-- Heading -->
<tr><td style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;font-size:24px;font-weight:300;color:#FFFFFF;letter-spacing:-0.5px;padding-bottom:24px;">
$heading
</td></tr>

<!-- Body -->
<tr><td style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;font-size:15px;font-weight:400;color:#9E9E9E;line-height:1.6;letter-spacing:0.3px;padding-bottom:36px;">
$bodyContent
</td></tr>

<!-- OTP code -->
<tr><td style="padding-bottom:36px;">
<table cellpadding="0" cellspacing="0" role="presentation">
<tr><td style="border:1px solid #424242;padding:24px 48px;font-family:'Courier New',Courier,monospace;font-size:32px;font-weight:300;color:#4A90E2;letter-spacing:8px;text-align:center;">
$escapedCode
</td></tr>
</table>
</td></tr>

<!-- Expiry note -->
<tr><td style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;font-size:13px;font-weight:400;color:#616161;line-height:1.6;letter-spacing:0.2px;padding-bottom:48px;">
$footerNote
</td></tr>

<!-- Divider -->
<tr><td style="padding-bottom:24px;">
<div style="width:100%;height:1px;background-color:#212121;"></div>
</td></tr>

<!-- Footer -->
<tr><td style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;font-size:11px;font-weight:400;color:#616161;letter-spacing:0.2px;">
Veda &mdash; sent to $escapedEmail
</td></tr>

</table>
</td></tr>
</table>
</body>
</html>''';
  }

  static String _escapeHtml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }
}
