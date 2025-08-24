import 'package:dart_frog/dart_frog.dart';
import 'package:mind_paystack/mind_paystack.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => await _exportTransactions(context),
    _ => Response(statusCode: 405, body: 'Method not allowed'),
  };
}

Future<Response> _exportTransactions(RequestContext context) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;

    final sdk = MindPaystack.instance;
    final options = ExportTransactionsOptions(
      perPage: body['per_page'] as int?,
      page: body['page'] as int?,
      from: body['from'] != null
          ? DateTime.tryParse(body['from'] as String)
          : null,
      to: body['to'] != null ? DateTime.tryParse(body['to'] as String) : null,
      customer: body['customer'] != null
          ? int.tryParse(body['customer'] as String)
          : null,
      status: body['status'] as String?,
      currency: body['currency'] as String?,
      amount: body['amount'] as int?,
      settled: body['settled'] as bool?,
      settlement: body['settlement'] != null
          ? int.tryParse(body['settlement'] as String)
          : null,
      paymentPage: body['payment_page'] != null
          ? int.tryParse(body['payment_page'] as String)
          : null,
    );

    final result = await sdk.transaction.export(options);

    // SDK's built-in serialization with export data
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
