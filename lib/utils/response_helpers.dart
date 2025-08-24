import 'package:dart_frog/dart_frog.dart';
import 'package:mind_paystack/mind_paystack.dart';

class ResponseHelpers {
  static Response handleMindException(MindException e) {
    return Response.json(
      statusCode: _getStatusCodeForException(e),
      body: {
        'status': false,
        'message': e.message,
        'code': e.code,
        if (e.technicalMessage != null) 'technical_message': e.technicalMessage,
        if (e.validationErrors?.isNotEmpty ?? false)
          'validation_errors':
              e.validationErrors?.map((err) => err.toJson()).toList(),
      },
    );
  }

  static Response handleGenericError(Object error) {
    return Response.json(
      statusCode: 500,
      body: {
        'status': false,
        'message': 'Internal server error',
        'error': error.toString(),
      },
    );
  }

  static Response success({
    required dynamic data,
    String? message,
    Map<String, dynamic>? meta,
    int statusCode = 200,
  }) {
    return Response.json(
      statusCode: statusCode,
      body: {
        'status': true,
        if (message != null) 'message': message,
        'data': data,
        if (meta != null) 'meta': meta,
      },
    );
  }

  static Response error({
    required String message,
    String? code,
    dynamic details,
    int statusCode = 400,
  }) {
    return Response.json(
      statusCode: statusCode,
      body: {
        'status': false,
        'message': message,
        if (code != null) 'code': code,
        if (details != null) 'details': details,
      },
    );
  }

  static int _getStatusCodeForException(MindException e) {
    if (e.code.contains('validation')) return 400;
    if (e.code.contains('not_found')) return 404;
    if (e.code.contains('unauthorized')) return 401;
    if (e.code.contains('forbidden')) return 403;
    if (e.code.contains('network')) return 502;
    return 400; // Default to bad request
  }
}
