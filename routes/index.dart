import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return switch (context.request.method) {
    HttpMethod.get => _welcomeMessage(context),
    _ => Response(statusCode: 405, body: 'Method not allowed'),
  };
}

Response _welcomeMessage(RequestContext context) {
  return Response.json(body: {
    'status': true,
    'message': 'Welcome to MindPaystack Server!',
    'version': '1.0.0',
    'description': 'A comprehensive Dart Frog server showcasing MindPaystack SDK usage',
    'initialization': 'SDK is auto-initialized from environment variables',
    'endpoints': {
      'POST /charge': 'Create charges with multiple payment methods',
      'POST /charge/submit/pin': 'Submit PIN for card authorization',
      'POST /charge/submit/otp': 'Submit OTP for card authorization', 
      'POST /charge/submit/phone': 'Submit phone for verification',
      'POST /charge/submit/birthday': 'Submit birthday for verification',
      'POST /charge/submit/address': 'Submit address for verification',
      'POST /charge/status': 'Check pending charge status',
      'POST /transaction': 'Initialize transaction',
      'GET /transaction': 'List transactions',
      'GET /transaction/verify/[reference]': 'Verify transaction',
      'GET /transaction/fetch/[id]': 'Fetch transaction by ID',
      'POST /transaction/charge_authorization': 'Charge saved authorization',
      'GET /transaction/timeline/[reference]': 'Get transaction timeline',
      'GET /transaction/totals': 'Get transaction totals',
      'POST /transaction/export': 'Export transactions',
      'POST /transaction/partial_debit': 'Perform partial debit',
    },
    'environment_variables': {
      'required': [
        'PAYSTACK_PUBLIC_KEY',
        'PAYSTACK_SECRET_KEY',
      ],
      'optional': [
        'PAYSTACK_ENVIRONMENT (test|live)',
        'PAYSTACK_LOG_LEVEL (debug|info|warning|error)',
      ],
    },
  });
}
