import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dotenv/dotenv.dart';
import 'package:mind_paystack/mind_paystack.dart';

Handler middleware(Handler handler) {
  return handler.use(requestLogger()).use(
        provider<Future<MindPaystack>>(
          (context) => init(
            context.request.connectionInfo.remoteAddress,
            context.request.connectionInfo.localPort,
          ),
        ),
      );
}

// This will be called automatically before serving any request
Future<MindPaystack> init(InternetAddress ip, int port) async {
  final env = DotEnv()..load();

  final publicKey =
      env['PAYSTACK_PUBLIC_KEY'] ?? Platform.environment['PAYSTACK_PUBLIC_KEY'];
  final secretKey =
      env['PAYSTACK_SECRET_KEY'] ?? Platform.environment['PAYSTACK_SECRET_KEY'];
  final environment = (env['PAYSTACK_ENVIRONMENT'] ??
          Platform.environment['PAYSTACK_ENVIRONMENT'] ??
          'test')
      .toLowerCase();
  final logLevel = (env['PAYSTACK_LOG_LEVEL'] ??
          Platform.environment['PAYSTACK_LOG_LEVEL'] ??
          'info')
      .toLowerCase();

  if (publicKey == null || secretKey == null) {
    throw Exception(
        'PAYSTACK_PUBLIC_KEY and PAYSTACK_SECRET_KEY are required.');
  }

  final config = PaystackConfig(
    publicKey: publicKey,
    secretKey: secretKey,
    environment:
        environment == 'live' ? Environment.production : Environment.test,
    logLevel: switch (logLevel) {
      'debug' => LogLevel.debug,
      'warning' => LogLevel.warning,
      'error' => LogLevel.error,
      _ => LogLevel.info,
    },
  );

  print('✅ MindPaystack initialized using .create()');
  return MindPaystack.create(config: config);
}
