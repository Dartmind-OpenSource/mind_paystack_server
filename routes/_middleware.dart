import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dotenv/dotenv.dart';
import 'package:mind_paystack/mind_paystack.dart';

Handler middleware(Handler handler) {
  return handler.use(requestLogger()).use(paystackInitializer());
}

Middleware paystackInitializer() {
  return provider<bool>((context) {
    // Initialize SDK once if not already done
    _initializePaystackSDK();
    return true;
  });
}

bool _sdkInitialized = false;

void _initializePaystackSDK() {
  if (_sdkInitialized) return;

  try {
    // Load environment variables
    final env = DotEnv()..load();

    final publicKey = env['PAYSTACK_PUBLIC_KEY'] ??
        Platform.environment['PAYSTACK_PUBLIC_KEY'];
    final secretKey = env['PAYSTACK_SECRET_KEY'] ??
        Platform.environment['PAYSTACK_SECRET_KEY'];
    final environment = env['PAYSTACK_ENVIRONMENT'] ??
        Platform.environment['PAYSTACK_ENVIRONMENT'] ??
        'test';
    final logLevel = env['PAYSTACK_LOG_LEVEL'] ??
        Platform.environment['PAYSTACK_LOG_LEVEL'] ??
        'info';

    if (publicKey == null || secretKey == null) {
      throw Exception(
        'PAYSTACK_PUBLIC_KEY and PAYSTACK_SECRET_KEY environment variables are required',
      );
    }

    final config = PaystackConfig(
      publicKey: publicKey,
      secretKey: secretKey,
      environment: environment == 'live' ? Environment.test : Environment.test,
      logLevel: switch (logLevel.toLowerCase()) {
        'debug' => LogLevel.debug,
        'info' => LogLevel.info,
        'warning' => LogLevel.warning,
        'error' => LogLevel.error,
        _ => LogLevel.info,
      },
    );

    MindPaystack.initialize(config);
    _sdkInitialized = true;
  } catch (e) {
    print('Failed to initialize MindPaystack SDK: $e');
    rethrow;
  }
}
