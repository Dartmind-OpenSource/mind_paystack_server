import 'package:dart_frog/dart_frog.dart';
import 'package:mind_paystack/mind_paystack.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => await _createSubscription(context),
    HttpMethod.get => await _listSubscriptions(context),
    _ => Response(statusCode: 405, body: 'Method not allowed'),
  };
}

Future<Response> _createSubscription(RequestContext context) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;

    // Use SDK's structured options - let it handle all validation
    final options = CreateSubscriptionOptions(
      customer: body['customer'] as String,
      plan: body['plan'] as String,
      authorization: body['authorization'] as String?,
      startDate: body['start_date'] != null
          ? DateTime.tryParse(body['start_date'] as String)
          : null,
      quantity: body['quantity'] as int?,
      metadata: body['metadata'] as Map<String, dynamic>?,
    );

    final sdk = MindPaystack.instance;
    final result = await sdk.subscription.create(options);

    // Use SDK's perfect serialization
    return Response.json(
      statusCode: result.isSuccess ? 200 : 400,
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

Future<Response> _listSubscriptions(RequestContext context) async {
  try {
    final queryParams = context.request.uri.queryParameters;

    // Use SDK's structured options for query parameters
    final options = ListSubscriptionsOptions(
      perPage: int.tryParse(queryParams['per_page'] ?? '50'),
      page: int.tryParse(queryParams['page'] ?? '1'),
      customer: queryParams['customer'],
      plan: queryParams['plan'],
      status: queryParams['status'],
    );

    final sdk = MindPaystack.instance;
    final result = await sdk.subscription.list(options);

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