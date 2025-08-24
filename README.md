# MindPaystack Server

A **production-ready** Dart Frog server showcasing **best practices** for using the MindPaystack SDK. This implementation leverages the SDK's excellent built-in features like automatic mapping, comprehensive error handling, and structured validation.

## 🎯 **Why This Implementation is Superior**

### ✅ **Leverages SDK's Built-in Features**
- **Structured Options**: Uses `InitializeTransactionOptions`, `CreateChargeOptions`, etc.
- **Automatic Validation**: SDK handles all input validation internally
- **Built-in Serialization**: Uses `.toJson()` methods for consistent responses
- **Comprehensive Error Handling**: Leverages `MindException` with detailed error information

### ✅ **Clean & Maintainable**
- **No Manual Validation**: SDK's options classes handle validation
- **Consistent Error Responses**: MindException provides standardized error format
- **Type Safety**: SDK's structured classes ensure type correctness
- **Minimal Boilerplate**: Let the SDK do the heavy lifting

## Features

- 🔒 **Secure Configuration**: SDK initialization from environment variables only
- 🚀 **SDK-First Approach**: Uses all SDK built-in features (validation, serialization, error handling)
- 🛡️ **Comprehensive Error Handling**: Leverages MindException's rich error details
- 📊 **All Payment Methods**: Cards, bank transfers, USSD, mobile money, saved cards
- 🔄 **Complete Transaction Management**: Initialize, verify, list, timeline, export
- 📝 **Type Safety**: Uses SDK's structured options classes

## Quick Start

### 1. Environment Setup

Create `.env` file:

```env
# Required
PAYSTACK_PUBLIC_KEY=pk_test_your_public_key_here
PAYSTACK_SECRET_KEY=sk_test_your_secret_key_here

# Optional
PAYSTACK_ENVIRONMENT=test
PAYSTACK_LOG_LEVEL=info
```

### 2. Run Server

```bash
dart pub get
dart_frog dev
```

## API Usage Examples

### 💳 **Card Payment**

The server uses the SDK's `chargeCard` convenience method:

```bash
curl -X POST http://localhost:8080/charge \
  -H "Content-Type: application/json" \
  -d '{
    "email": "customer@example.com",
    "amount": "50000",
    "payment_method": "card",
    "card": {
      "number": "4084084084084081",
      "cvv": "123",
      "expiry_month": "12",
      "expiry_year": "2025"
    },
    "pin": "1234"
  }'
```

### 🏦 **Bank Transfer Payment**

Uses SDK's `chargeBankTransfer` method:

```bash
curl -X POST http://localhost:8080/charge \
  -H "Content-Type: application/json" \
  -d '{
    "email": "customer@example.com",
    "amount": "50000",
    "payment_method": "bank_transfer"
  }'
```

### 💾 **Saved Card Payment**

Uses SDK's `chargeSavedCard` method:

```bash
curl -X POST http://localhost:8080/charge \
  -H "Content-Type: application/json" \
  -d '{
    "email": "customer@example.com",
    "amount": "50000",
    "payment_method": "saved_card",
    "authorization_code": "AUTH_abc123def"
  }'
```

### 🔐 **PIN Submission**

Uses structured `SubmitPinOptions`:

```bash
curl -X POST http://localhost:8080/charge/submit/pin \
  -H "Content-Type: application/json" \
  -d '{
    "reference": "transaction_reference",
    "pin": "1234"
  }'
```

### 🚀 **Transaction Initialization**

Uses `InitializeTransactionOptions` with full validation:

```bash
curl -X POST http://localhost:8080/transaction \
  -H "Content-Type: application/json" \
  -d '{
    "email": "customer@example.com",
    "amount": "50000",
    "callback_url": "https://your-site.com/callback",
    "channels": ["card", "bank", "ussd"],
    "metadata": {
      "order_id": "12345"
    }
  }'
```

### ✅ **Transaction Verification**

Simple and clean with SDK handling everything:

```bash
curl http://localhost:8080/transaction/verify/your_transaction_reference
```

## Code Examples

### **Before**: Manual Validation & Error Handling ❌

```dart
// DON'T DO THIS
Future<Response> _createCharge(RequestContext context) async {
  final body = await context.request.json() as Map<String, dynamic>;
  
  // Manual validation (unnecessary!)
  final email = body['email'] as String?;
  if (email == null || !email.contains('@')) {
    return Response.json(statusCode: 400, body: {'error': 'Invalid email'});
  }
  
  // Manual error handling (reinventing the wheel!)
  try {
    final card = Card(/*...*/);
    final result = await sdk.charge.chargeCard(/*...*/);
    
    return Response.json(body: {
      'status': result.status,
      'message': result.message,
      'data': result.data?.toJson(), // Manual serialization
    });
  } catch (e) {
    return Response.json(statusCode: 500, body: {'error': e.toString()});
  }
}
```

### **After**: Leveraging SDK's Built-in Features ✅

```dart
// DO THIS - Clean, simple, and leverages all SDK features!
Future<Response> _createCharge(RequestContext context) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    
    // Use SDK's convenience methods - they handle validation!
    final email = body['email'] as String;
    final amount = body['amount'] as String;
    final card = Card(/*...*/);
    
    final result = await MindPaystack.instance.charge.chargeCard(
      email: email,
      amount: amount,
      card: card,
    );
    
    // SDK's built-in serialization handles everything!
    return Response.json(
      statusCode: result.status ? 200 : 400,
      body: result.toJson(), // ✨ Perfect serialization
    );
    
  } on MindException catch (e) {
    // SDK's comprehensive error handling!
    return Response.json(
      statusCode: 400,
      body: e.toJson(), // ✨ Complete error details
    );
  }
}
```

## Response Format

All responses use the SDK's built-in serialization:

### Success Response (from SDK)
```json
{
  "status": true,
  "message": "Charge created successfully",
  "data": {
    "id": 123456789,
    "reference": "tx_abc123",
    "amount": 50000,
    "currency": "NGN",
    "status": "success",
    // ... complete transaction details from SDK
  }
}
```

### Error Response (from SDK's MindException)
```json
{
  "message": "Invalid card number",
  "code": "invalid_card_number",
  "category": "validation",
  "severity": "error",
  "technicalMessage": "Card number fails Luhn algorithm check",
  "validationErrors": [
    {
      "field": "card.number",
      "message": "Invalid card number format"
    }
  ]
}
```

## Key Implementation Insights

### 🎯 **1. Use SDK's Convenience Methods**
Instead of manual charge creation, use:
- `sdk.charge.chargeCard()`
- `sdk.charge.chargeBankTransfer()`
- `sdk.charge.chargeSavedCard()`

### 🎯 **2. Leverage Structured Options**
Use SDK's option classes:
- `InitializeTransactionOptions`
- `SubmitPinOptions`
- `ListTransactionsOptions`

### 🎯 **3. Trust SDK's Error Handling**
`MindException` provides:
- Structured error codes
- Validation details
- Technical messages
- User-friendly messages

### 🎯 **4. Use Built-in Serialization**
Always use `.toJson()` methods:
- `result.toJson()` for responses
- `exception.toJson()` for errors

## Architecture Benefits

1. **Less Code**: SDK handles validation, serialization, error formatting
2. **Better Errors**: Rich error details from MindException
3. **Type Safety**: SDK's structured classes prevent runtime errors
4. **Consistency**: All responses use SDK's standardized format
5. **Maintainability**: Changes in SDK automatically benefit your server
6. **Testing**: SDK's structured approach makes testing easier

## Production Deployment

The server is designed for production with:

- **Environment-based configuration**
- **Comprehensive error handling via SDK**
- **Type-safe request handling**
- **Consistent response formatting**
- **Zero hardcoded credentials**

## Contributing

This implementation demonstrates:
- **Best practices** for SDK usage
- **Production-ready** patterns
- **Clean architecture** leveraging existing SDK features
- **Comprehensive examples** for all payment methods

The key insight: **Don't reinvent what the SDK already does perfectly!** 🚀