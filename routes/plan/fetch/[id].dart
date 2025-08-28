import 'package:dart_frog/dart_frog.dart';
import 'package:mind_paystack/mind_paystack.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.get => await _fetchPlan(context, id),
    HttpMethod.put => await _updatePlan(context, id),
    _ => Response(statusCode: 405, body: 'Method not allowed'),
  };
}

Future<Response> _fetchPlan(RequestContext context, String id) async {
  try {
    final sdk = MindPaystack.instance;
    final result = await sdk.plan.fetch(id);

    return Response.json(
      statusCode: result.isSuccess ? 200 : 404,
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

Future<Response> _updatePlan(RequestContext context, String id) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;

    // Use SDK's structured options for updates
    final options = UpdatePlanOptions(
      name: body['name'] as String?,
      // interval: body['interval'] as String?,
      amount: int.tryParse(body['amount'] as String),
      description: body['description'] as String?,
      currency: body['currency'] as String?,
      invoiceLimit: body['invoice_limit'] as int?,
      sendInvoices: body['send_invoices'] as bool?,
      sendSms: body['send_sms'] as bool?,
    );

    final sdk = MindPaystack.instance;
    final result = await sdk.plan.update(id, options);

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
