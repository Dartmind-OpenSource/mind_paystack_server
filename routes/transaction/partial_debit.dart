import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:mind_paystack/mind_paystack.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => await _partialDebit(context),
    _ => Response(statusCode: 405, body: 'Method not allowed'),
  };
}

Future<Response> _partialDebit(RequestContext context) async {
  try {
    final body = await context.request.json();
    
    final authorizationCode = body['authorization_code'] as String?;
    final currency = body['currency'] as String?;
    final amount = body['amount'] as String?;
    final email = body['email'] as String?;
    
    if (authorizationCode == null || 
        currency == null || 
        amount == null || 
        email == null) {
      return Response.json(
        statusCode: 400,
        body: {
          'status': false,
          'message': 'Missing required fields: authorization_code, currency, amount, email',
        },
      );
    }
    
    final sdk = MindPaystack.instance;
    final options = PartialDebitOptions(
      authorizationCode: authorizationCode,
      currency: currency,
      amount: amount,
      email: email,
      reference: body['reference'] as String?,
      atLeast: body['at_least'] as String?,
    );
    
    final result = await sdk.transaction.partialDebit(options);
    
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