import 'package:dart_frog/dart_frog.dart';
import 'package:mind_paystack/mind_paystack.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => await _createPlan(context),
    HttpMethod.get => await _listPlans(context),
    _ => Response(statusCode: 405, body: 'Method not allowed'),
  };
}

Future<Response> _createPlan(RequestContext context) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;

    // Use SDK's structured options - let it handle all validation
    final options = CreatePlanOptions(
      name: body['name'] as String,
      interval: body['interval'] as String,
      amount: int.parse(body['amount'] as String),
      description: body['description'] as String?,
      currency: body['currency'] as String?,
      invoiceLimit: body['invoice_limit'] as int?,
      sendInvoices: body['send_invoices'] as bool?,
      sendSms: body['send_sms'] as bool?,
    );

    final sdk = MindPaystack.instance;
    final result = await sdk.plan.create(options);

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

Future<Response> _listPlans(RequestContext context) async {
  try {
    final queryParams = context.request.uri.queryParameters;

    // Use SDK's structured options for query parameters
    final options = ListPlansOptions(
      perPage: int.tryParse(queryParams['per_page'] ?? '50'),
      page: int.tryParse(queryParams['page'] ?? '1'),
      status: queryParams['status'],
      interval: queryParams['interval'],
      amount: int.parse(queryParams['amount'].toString()),
    );

    final sdk = MindPaystack.instance;
    final result = await sdk.plan.list(options);

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
