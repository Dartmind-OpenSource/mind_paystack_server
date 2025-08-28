import 'package:dart_frog/dart_frog.dart';
import 'package:mind_paystack/mind_paystack.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.post => await _disableSubscription(context, id),
    _ => Response(statusCode: 405, body: 'Method not allowed'),
  };
}

Future<Response> _disableSubscription(RequestContext context, String id) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>?;

    // Use SDK's structured options if token is provided
    final options = body?['token'] != null
        ? DisableSubscriptionOptions(token: body!['token'] as String)
        : null;

    final sdk = MindPaystack.instance;
    final result = await sdk.subscription.disable(id, options);

    return Response.json(
      statusCode: result.isSuccess ? 200 : 400,
      body: result.toJson(),
    );
  } on MindException catch (e) {
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