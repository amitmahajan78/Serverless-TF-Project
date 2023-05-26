const AWS = require('aws-sdk');

const dynamo = new AWS.DynamoDB.DocumentClient();

/**
 * Creating fx payment record in DynamoDB for further processing.
 */
exports.handler = async (event, context, callback) => {
  //console.log('Received event:', JSON.stringify(event, null, 2));
  const paymentId = 'PYID' + new Date().getTime().toString().substr(2, 9);
  var requestBody = '';

  try {
    requestBody = JSON.parse(event.body);
  } catch (e) {
    requestBody = event.body;
  }

  const putItemBody = {
    TableName: 'fx-payments',
    Item: {
      paymentId: paymentId,
      destinationCurrency: requestBody.destinationCurrency,
      amount: requestBody.amount,
      payeeName: requestBody.payeeName,
      beneficiaryName: requestBody.beneficiaryName,
      beneficiaryBankName: requestBody.beneficiaryBankName,
      beneficiaryAccountNo: requestBody.beneficiaryAccountNo,
      quoteId: requestBody.quoteId,
      paymentStatus: 'PAYMENT_CREATED',
    },
  };

  let statusCode = '200';
  let message =
    'Please use paymentId for getting latest status of your remittance by calling [GET] /payments?paymentId=' +
    paymentId;

  try {
    await dynamo.put(putItemBody).promise();
  } catch (err) {
    statusCode = '400';
    message = err.message;
  }

  const response = {
    statusCode: statusCode,
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      message: message,
    }),
  };

  callback(null, response);
};
