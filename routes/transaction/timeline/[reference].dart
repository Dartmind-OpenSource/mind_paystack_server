import 'package:dart_frog/dart_frog.dart';
import 'package:mind_paystack/mind_paystack.dart';

Future<Response> onRequest(RequestContext context, String reference) async {
  return switch (context.request.method) {
    HttpMethod.get => await _getTransactionTimeline(context, reference),
    _ => Response(statusCode: 405, body: 'Method not allowed'),
  };
}

Future<Response> _getTransactionTimeline(
  RequestContext context,
  String reference,
) async {
  try {
    // SDK handles all validation - just pass the reference
    final sdk = await context.read<Future<MindPaystack>>();
    final result = await sdk.transaction.timeline(reference);

    // SDK's built-in serialization with perfect timeline data
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
