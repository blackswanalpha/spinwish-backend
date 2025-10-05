# M-Pesa Daraja Integration Testing Guide

## Overview
This guide provides comprehensive testing procedures for the M-Pesa Daraja integration in SpinWish.

## Test Environment Setup

### 1. Backend Configuration
Ensure the following properties are set in `application-test.properties`:
```properties
mpesa.consumerKey=XYqlsU1XIaW5h1KLXQaHXK9tluH8cxLvjxfYe4GaaQCZmjtF
mpesa.consumerSecret=F3pLoXkXj5SncaAtAim4B0OshnICwKDi2QGySFnzznGTrGDs4u4M4D7xnrfTBDBY
mpesa.shortCode=174379
mpesa.callback-url=http://localhost:8080/api/v1/payment/mpesa/callback
```

### 2. Test Phone Numbers (Sandbox)
Use these Safaricom sandbox test numbers:
- `254708374149` - Success scenario
- `254711111111` - Insufficient funds
- `254722222222` - Invalid account
- `254733333333` - Timeout scenario

## Integration Tests

### 1. Configuration Test
```bash
cd backend && ./mvnw test -Dtest=MpesaIntegrationTest#testMpesaConfigurationLoaded
```

### 2. Request Validation Test
```bash
cd backend && ./mvnw test -Dtest=MpesaIntegrationTest#testMpesaRequestValidation
```

### 3. Phone Number Formatting Test
```bash
cd backend && ./mvnw test -Dtest=MpesaIntegrationTest#testPhoneNumberFormatting
```

## Manual Testing Procedures

### 1. STK Push Testing

#### Test Case 1: Successful Payment
1. **Endpoint**: `POST /api/v1/payment/mpesa/stkpush`
2. **Payload**:
```json
{
  "phoneNumber": "254708374149",
  "amount": "100",
  "requestId": "test-request-123"
}
```
3. **Expected Result**: STK push sent successfully
4. **Verification**: Check callback endpoint receives success response

#### Test Case 2: Insufficient Funds
1. **Payload**:
```json
{
  "phoneNumber": "254711111111",
  "amount": "100",
  "requestId": "test-request-124"
}
```
2. **Expected Result**: STK push sent, but payment fails
3. **Verification**: Callback receives failure with appropriate error code

#### Test Case 3: Invalid Phone Number
1. **Payload**:
```json
{
  "phoneNumber": "254999999999",
  "amount": "100",
  "requestId": "test-request-125"
}
```
2. **Expected Result**: Validation error before STK push
3. **Verification**: Error response with validation message

### 2. Callback Testing

#### Test Case 1: Success Callback
1. **Endpoint**: `POST /api/v1/payment/mpesa/callback`
2. **Payload**: (Simulated Safaricom callback)
```json
{
  "Body": {
    "stkCallback": {
      "MerchantRequestID": "29115-34620561-1",
      "CheckoutRequestID": "ws_CO_191220191020363925",
      "ResultCode": 0,
      "ResultDesc": "The service request is processed successfully.",
      "CallbackMetadata": {
        "Item": [
          {
            "Name": "Amount",
            "Value": 100.00
          },
          {
            "Name": "MpesaReceiptNumber",
            "Value": "NLJ7RT61SV"
          },
          {
            "Name": "TransactionDate",
            "Value": 20191219102115
          },
          {
            "Name": "PhoneNumber",
            "Value": 254708374149
          }
        ]
      }
    }
  }
}
```
3. **Expected Result**: Transaction saved successfully
4. **Verification**: Check database for transaction record

### 3. Status Query Testing

#### Test Case 1: Query Successful Transaction
1. **Endpoint**: `GET /api/v1/payment/stk/query/{checkoutRequestId}`
2. **Parameter**: Use CheckoutRequestID from successful STK push
3. **Expected Result**: Transaction status returned
4. **Verification**: Status matches database record

## Flutter App Testing

### 1. Payment Flow Testing
1. Open SpinWish app
2. Navigate to payment screen
3. Enter test phone number: `254708374149`
4. Enter amount: `100`
5. Initiate payment
6. Verify STK push received on test phone
7. Complete payment on phone
8. Verify app receives success confirmation

### 2. Error Handling Testing
1. Test with invalid phone number
2. Test with insufficient funds scenario
3. Test network timeout scenarios
4. Verify appropriate error messages displayed

## Production Testing Checklist

### Before Going Live:
- [ ] Update M-Pesa credentials to production values
- [ ] Update callback URL to production domain
- [ ] Verify callback URL is accessible from Safaricom servers
- [ ] Test with real phone numbers and small amounts
- [ ] Verify SSL certificate on callback endpoint
- [ ] Test error scenarios in production environment
- [ ] Monitor logs for any issues
- [ ] Set up alerting for payment failures

### Production Credentials Setup:
```properties
# Production M-Pesa Configuration
mpesa.consumerKey=${MPESA_PROD_CONSUMER_KEY}
mpesa.consumerSecret=${MPESA_PROD_CONSUMER_SECRET}
mpesa.shortCode=${MPESA_PROD_SHORT_CODE}
mpesa.passkey=${MPESA_PROD_PASSKEY}
mpesa.baseUrl=https://api.safaricom.co.ke/mpesa/stkpush/v1/processrequest
mpesa.token-url=https://api.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials
mpesa.stkQueryUrl=https://api.safaricom.co.ke/mpesa/stkpushquery/v1/query
mpesa.callback-url=https://your-production-domain.com/api/v1/payment/mpesa/callback
```

## Troubleshooting Common Issues

### 1. "Invalid Access Token"
- **Cause**: Expired or invalid OAuth token
- **Solution**: Check consumer key/secret, verify token generation logic

### 2. "Invalid Phone Number"
- **Cause**: Phone number format issues
- **Solution**: Verify phone number formatting (254XXXXXXXXX)

### 3. "Callback Not Received"
- **Cause**: Callback URL not accessible
- **Solution**: Verify URL accessibility, check firewall settings

### 4. "Transaction Timeout"
- **Cause**: User didn't complete payment in time
- **Solution**: Implement proper timeout handling and user notifications

## Monitoring and Logging

### Key Metrics to Monitor:
- Payment success rate
- Average payment completion time
- Callback response times
- Error rates by type
- Failed transaction reasons

### Log Analysis:
- Monitor payment initiation logs
- Track callback processing logs
- Alert on high error rates
- Monitor database transaction consistency
