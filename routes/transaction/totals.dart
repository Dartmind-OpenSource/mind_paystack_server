import 'package:dart_frog/dart_frog.dart';
import 'package:mind_paystack/mind_paystack.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => await _getTransactionTotals(context),
    _ => Response(statusCode: 405, body: 'Method not allowed'),
  };
}

Future<Response> _getTransactionTotals(RequestContext context) async {
  try {
    // No parameters needed - SDK handles everything
    final sdk = MindPaystack.instance;
    final result = await sdk.transaction.totals();
    
    // SDK's built-in serialization with complete totals data
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