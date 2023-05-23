const AWS = require('aws-sdk');
const documentClient = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event, context, callback) => {
  let resBody = '';
  console.log('Get Payment Status log : ' + JSON.stringify(event));

  console.log('PaumentID : ' + event.queryStringParameters.paymentId);

  var params = {
    TableName: 'fx-payments',
    Key: {
      paymentId: event.queryStringParameters.paymentId,
    },
  };

  await documentClient
    .get(params, function (err, data) {
      if (err) {
        console.log('Error', err);
        resBody = err;
      } else {
        resBody = data.Item;
      }
    })
    .promise();

  console.log('Dynamodb record ' + JSON.stringify(resBody));

  // TODO implement
  const response = {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
    },
    body:
      resBody == null
        ? JSON.stringify({ message: 'no record found' })
        : JSON.stringify(resBody),
  };

  callback(null, response);
};
