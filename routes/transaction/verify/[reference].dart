import 'package:dart_frog/dart_frog.dart';
import 'package:mind_paystack/mind_paystack.dart';

Future<Response> onRequest(RequestContext context, String reference) async {
  return switch (context.request.method) {
    HttpMethod.get => await _verifyTransaction(context, reference),
    _ => Response(statusCode: 405, body: 'Method not allowed'),
  };
}

Future<Response> _verifyTransaction(
  RequestContext context,
  String reference,
) async {
  try {
    // SDK handles all validation internally - no need for manual checks!
    final sdk = await context.read<Future<MindPaystack>>();
    final result = await sdk.transaction.verify(reference);

    // SDK's built-in serialization handles everything perfectly
    return Response.json(
      statusCode: result.status ? 200 : 400,
      body: result.toJson(),
    );
  } on MindException catch (e) {
    // SDK's comprehensive error details with validation, codes, etc.
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
