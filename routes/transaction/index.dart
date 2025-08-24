import 'package:dart_frog/dart_frog.dart';
import 'package:mind_paystack/mind_paystack.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => await _initializeTransaction(context),
    HttpMethod.get => await _listTransactions(context),
    _ => Response(statusCode: 405, body: 'Method not allowed'),
  };
}

Future<Response> _initializeTransaction(RequestContext context) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;

    // Use SDK's structured options - let it handle all validation
    final options = InitializeTransactionOptions(
      email: body['email'] as String,
      amount: body['amount'] as String,
      reference: body['reference'] as String?,
      callbackUrl: body['callback_url'] as String?,
      channels: (body['channels'] as List<dynamic>?)?.cast<String>(),
      metadata: body['metadata'] as Map<String, dynamic>?,
    );

    final sdk = await context.read<Future<MindPaystack>>();
    final result = await sdk.transaction.initialize(options);

    // Use SDK's perfect serialization
    return Response.json(
      statusCode: result.status ? 200 : 400,
      body: result.toMap(),
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

Future<Response> _listTransactions(RequestContext context) async {
  try {
    final queryParams = context.request.uri.queryParameters;

    // Use SDK's structured options for query parameters
    final options = ListTransactionsOptions(
      perPage: int.tryParse(queryParams['per_page'] ?? '50'),
      page: int.tryParse(queryParams['page'] ?? '1'),
      customer: int.tryParse(queryParams['customer'] ?? '-1'),
      status: queryParams['status'],
      from: queryParams['from'] != null
          ? DateTime.tryParse(queryParams['from']!)
          : null,
      to: queryParams['to'] != null
          ? DateTime.tryParse(queryParams['to']!)
          : null,
      amount: int.tryParse(queryParams['amount'] ?? '') ?? 0,
    );

    final sdk = MindPaystack.instance;
    final result = await sdk.transaction.list(options);

    return Response.json(
      statusCode: result.status ? 200 : 400,
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
