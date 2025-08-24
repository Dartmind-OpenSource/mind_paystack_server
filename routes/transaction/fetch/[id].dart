import 'package:dart_frog/dart_frog.dart';
import 'package:mind_paystack/mind_paystack.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.get => await _fetchTransaction(context, id),
    _ => Response(statusCode: 405, body: 'Method not allowed'),
  };
}

Future<Response> _fetchTransaction(RequestContext context, String id) async {
  try {
    // Parse ID and let SDK handle validation
    final transactionId = int.tryParse(id);
    if (transactionId == null || transactionId <= 0) {
      // Simple validation before calling SDK
      return Response.json(
        statusCode: 400,
        body: {
          'status': false,
          'message': 'Invalid transaction ID format',
        },
      );
    }

    final sdk = await context.read<Future<MindPaystack>>();
    final result = await sdk.transaction.fetch(transactionId);

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
