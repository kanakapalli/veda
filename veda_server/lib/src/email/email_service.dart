import 'dart:io';

import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server/gmail.dart';
import 'package:serverpod/serverpod.dart';

import 'email_templates.dart';

/// Sends transactional emails via Gmail SMTP.
///
/// Because the auth callbacks have a `void` return type (not `Future<void>`),
/// the session may close before the async SMTP send completes. All session
/// access (passwords, logging) is done synchronously before any `await`.
/// Post-send logging uses [stdout]/[stderr] instead of [Session.log].
class EmailService {
  EmailService._();

  static Future<void> sendRegistrationCode(
    Session session, {
    required String email,
    required String verificationCode,
  }) async {
    // Read session data synchronously — session may close after we return.
    session.log('[EmailIdp] Registration code ($email): $verificationCode');
    final credentials = _readCredentials(session, 'registration verification');

    if (credentials == null) return;

    await _sendEmail(
      credentials: credentials,
      recipientEmail: email,
      subject: 'Verify your email — Veda',
      htmlBody: EmailTemplates.registrationVerificationCode(
        verificationCode: verificationCode,
        recipientEmail: email,
      ),
      logContext: 'registration verification',
    );
  }

  static Future<void> sendPasswordResetCode(
    Session session, {
    required String email,
    required String verificationCode,
  }) async {
    session.log('[EmailIdp] Password reset code ($email): $verificationCode');
    final credentials = _readCredentials(session, 'password reset');

    if (credentials == null) return;

    await _sendEmail(
      credentials: credentials,
      recipientEmail: email,
      subject: 'Reset your password — Veda',
      htmlBody: EmailTemplates.passwordResetVerificationCode(
        verificationCode: verificationCode,
        recipientEmail: email,
      ),
      logContext: 'password reset',
    );
  }

  /// Reads SMTP credentials from the session synchronously.
  /// Returns `null` and logs a warning if any credential is missing.
  static _SmtpCredentials? _readCredentials(
    Session session,
    String logContext,
  ) {
    final username = session.passwords['smtpUsername'];
    final password = session.passwords['smtpPassword'];
    final fromEmail = session.passwords['smtpFromEmail'];

    if (username == null || password == null || fromEmail == null) {
      session.log(
        '[EmailService] SMTP credentials not configured. '
        'Skipping $logContext email. '
        'Set smtpUsername, smtpPassword, and smtpFromEmail in passwords.yaml.',
        level: LogLevel.warning,
      );
      return null;
    }

    return _SmtpCredentials(
      username: username,
      password: password,
      fromEmail: fromEmail,
    );
  }

  /// Sends the email via Gmail SMTP. Uses [stdout]/[stderr] for logging
  /// because the Serverpod session may already be closed at this point.
  static Future<void> _sendEmail({
    required _SmtpCredentials credentials,
    required String recipientEmail,
    required String subject,
    required String htmlBody,
    required String logContext,
  }) async {
    try {
      final smtpServer = gmail(credentials.username, credentials.password);

      final message = mailer.Message()
        ..from = mailer.Address(credentials.fromEmail, 'Veda')
        ..recipients.add(recipientEmail)
        ..subject = subject
        ..html = htmlBody;

      final sendReport = await mailer.send(message, smtpServer);
      stdout.writeln(
        '[EmailService] Sent $logContext email to $recipientEmail. '
        'Report: $sendReport',
      );
    } on mailer.MailerException catch (e) {
      stderr.writeln(
        '[EmailService] Failed to send $logContext email to $recipientEmail: '
        '${e.message}',
      );
      for (final problem in e.problems) {
        stderr.writeln(
          '[EmailService] Problem: ${problem.code} – ${problem.msg}',
        );
      }
    } catch (e, stackTrace) {
      stderr.writeln(
        '[EmailService] Unexpected error sending $logContext email to '
        '$recipientEmail: $e\n$stackTrace',
      );
    }
  }
}

class _SmtpCredentials {
  final String username;
  final String password;
  final String fromEmail;

  const _SmtpCredentials({
    required this.username,
    required this.password,
    required this.fromEmail,
  });
}
