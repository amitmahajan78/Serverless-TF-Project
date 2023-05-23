const AWS = require('aws-sdk');
const documentClient = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  console.log('Payment Completed Logs: ' + JSON.stringify(event));

  const body = event.detail.message;
  console.log(
    'Updating payment id: ' +
      body.paymentId.S +
      ' and payment status: ' +
      body.paymentStatus.S
  );

  // Build the update expression
  const updateItems = {
    TableName: 'fx-payments',
    Key: {
      paymentId: body.paymentId.S,
    },
    UpdateExpression: 'SET paymentStatus = :name',
    ExpressionAttributeValues: {
      ':name':
        body.paymentStatus.S === 'FxPayment sent for fulfilment'
          ? 'FxPayment Completed'
          : 'Waiting for fulfilment',
    },
  };

  try {
    await documentClient.update(updateItems).promise();
    console.log('Item updated successfully');
  } catch (error) {
    console.error(error);
  }

  return {};
};
