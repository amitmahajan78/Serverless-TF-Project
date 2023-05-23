## Setup API variables

## Replace these environment variables with your values

export API_ID=qq7ezoal41
export AWS_REGION=eu-west-1
export API_STAGE=stage

## Testing /quotes POSt API

### Successful scenario 
```
curl -X POST \
     -H "Content-Type: application/json" \
     -d '{"destinationCurrency": "GBP","amount": 1000}' \
     https://nqwnig494b.execute-api.eu-west-1.amazonaws.com/stage/payments
```

### Amount check error scenario 
```
curl -X POST \
     -H "Content-Type: application/json" \
     -d '{"destinationCurrency": "GBP","amount": 100000}' \
     https://$API_ID.execute-api.$AWS_REGION.amazonaws.com/$API_STAGE/quotes
```
### Invalid request body scenario 
```
curl -X POST \
     -H "Content-Type: application/json" \
     -d '{"destinationCurrency": "GBP"}' \
     https://$API_ID.execute-api.$AWS_REGION.amazonaws.com/$API_STAGE/quotes
```

## Testing /fx-payments POST

### Testing successful request
```
curl -X POST \
     -H "Content-Type: application/json" \
     -d '{"destinationCurrency": "GBP", "amount": 1000, "payeeName": "John", "beneficiaryName": "Alex", "beneficiaryBankName": "HSBC", "beneficiaryAccountNo": "1234", "quoteId": "1001"}' \
     https://$API_ID.execute-api.$AWS_REGION.amazonaws.com/$API_STAGE/fx-payments
```

### Testing invalid request body
```
curl -X POST \
     -H "Content-Type: application/json" \
     -d '{"destinationCurrency": "GBP123", "amount": 1000, "payeeName": "John", "beneficiaryName": "Alex", "beneficiaryBankName": "HSBC", "beneficiaryAccountNo": "1234", "quoteId": "1001"}' \
     https://$API_ID.execute-api.$AWS_REGION.amazonaws.com/$API_STAGE/fx-payments
```

## Testing /fx-payments GET 

### Testing successful request
```
curl "https://$API_ID.execute-api.$AWS_REGION.amazonaws.com/$API_STAGE/fx-payments?paymentId=PYID841547635"
```

## POST /fx-payments with Authorization token (Create payment)

```
curl -X POST \
     -H "Content-Type: application/json" \
     -H "Authorization: secrettoken" \
     -d '{"destinationCurrency": "GBP", "amount": 1000, "payeeName": "John", "beneficiaryName": "Alex", "beneficiaryBankName": "HSBC", "beneficiaryAccountNo": "1234", "quoteId": "1001"}' \
      https://nqwnig494b.execute-api.eu-west-1.amazonaws.com/stage/payments
```     

## GET /fx-payments with authorization token (Get payment)

```
curl -H "Authorization: secrettoken" "https://nqwnig494b.execute-api.eu-west-1.amazonaws.com/stage/payments"
```