import 'package:dart_frog/dart_frog.dart';
import 'package:mind_paystack/mind_paystack.dart';

/// Helper class for common API response patterns using MindPaystack SDK
class ApiHelpers {
  /// Creates a standardized response using SDK's built-in serialization
  static Response createResponse({
    required bool status,
    required int statusCode,
    dynamic data,
  }) {
    if (data is Resource) {
      return Response.json(
        statusCode: statusCode,
        body: data.toJson(),
      );
    } else if (data is MindException) {
      return Response.json(
        statusCode: statusCode,
        body: data.toJson(),
      );
    } else {
      return Response.json(
        statusCode: statusCode,
        body: data ?? {'status': status},
      );
    }
  }

  /// Gets appropriate HTTP status code from MindException
  static int getStatusCodeFromMindException(MindException e) {
    // Use SDK's error properties for proper HTTP mapping
    if (e.code.contains('validation') || e.code.contains('invalid')) {
      return 400;
    } else if (e.code.contains('unauthorized') || e.code.contains('auth')) {
      return 401;
    } else if (e.code.contains('forbidden') || e.code.contains('permission')) {
      return 403;
    } else if (e.code.contains('not_found') || e.code.contains('missing')) {
      return 404;
    } else if (e.code.contains('rate_limit') || e.code.contains('throttle')) {
      return 429;
    } else if (e.code.contains('server') || e.code.contains('internal')) {
      return 500;
    } else if (e.code.contains('network') || e.code.contains('connection')) {
      return 502;
    }
    
    return 400; // Default to bad request
  }

  /// Standard error response for unexpected exceptions
  static Response createErrorResponse(Object error, {int statusCode = 500}) {
    return Response.json(
      statusCode: statusCode,
      body: {
        'status': false,
        'message': 'Internal server error',
        'error': error.toString(),
      },
    );
  }

  /// Handles the common pattern of SDK operations
  static Future<Response> handleSdkOperation<T, O>(
    Future<Resource<T>> Function(O options) operation,
    O options,
  ) async {
    try {
      final result = await operation(options);
      return createResponse(
        status: result.status,
        statusCode: result.status ? 200 : 400,
        data: result,
      );
    } on MindException catch (e) {
      return createResponse(
        status: false,
        statusCode: getStatusCodeFromMindException(e),
        data: e,
      );
    } catch (e) {
      return createErrorResponse(e);
    }
  }
}