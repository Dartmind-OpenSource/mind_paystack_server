import 'package:dart_frog/dart_frog.dart';
import 'package:mind_paystack/mind_paystack.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => await _chargeAuthorization(context),
    _ => Response(statusCode: 405, body: 'Method not allowed'),
  };
}

Future<Response> _chargeAuthorization(RequestContext context) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    
    // Extract required fields and let SDK handle the rest
    final authorizationCode = body['authorization_code'] as String;
    final amount = body['amount'] as String;
    final email = body['email'] as String;
    
    // Convert amount to int for SDK convenience method
    final amountValue = int.tryParse(amount);
    if (amountValue == null || amountValue <= 0) {
      return Response.json(
        statusCode: 400,
        body: {
          'status': false,
          'message': 'Invalid amount value',
        },
      );
    }
    
    final sdk = MindPaystack.instance;
    
    // Use SDK's convenient method for charging authorizations
    final result = await sdk.transaction.chargeAuthorization(
      authorizationCode: authorizationCode,
      amount: amountValue,
      email: email,
    );
    
    // SDK's built-in serialization
    return Response.json(
      statusCode: result.status ? 200 : 400,
      body: result.toJson(),
    );
    
  } on MindException catch (e) {
    // SDK's comprehensive error handling
    return Response.json(
      statusCode: 400,
      body: e.toJson(),
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {
        'status': false,
        'message': 'Internal server error',
        'details': e.toString(),
      },
    );
  }
}