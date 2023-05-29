const AWS = require('aws-sdk');
const documentClient = new AWS.DynamoDB.DocumentClient();
const eventbridge = new AWS.EventBridge();

exports.handler = async function (event, context) {
  console.log(JSON.parse(JSON.stringify(event)));

  const bulkUpdatePromises = event.Records.map(async (record) => {
    console.log('FxPayment received: ' + record.body);

    const body = JSON.parse(record.body);
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
        ':name': 'PAYMENT_SENT_FOR_FULFILLMENT',
      },
    };

    try {
      await documentClient.update(updateItems).promise();
      console.log('Item updated successfully');
    } catch (error) {
      console.error(error);
    }

    const randomNum = Math.random();
    console.log('random number value : ' + randomNum);
    const sendItem = {
      Entries: [
        {
          Detail: JSON.stringify({
            message: {
              payeeName: {
                S: body.payeeName.S,
              },
              amount: {
                N: body.amount.N,
              },
              beneficiaryName: {
                S: body.beneficiaryName.S,
              },
              paymentId: {
                S: body.paymentId.S,
              },
              paymentStatus: {
                S:
                  randomNum > 0.25
                    ? 'PAYMENT_SENT_FOR_FULFILLMENT'
                    : 'PAYMENT_ERROR',
              },
              destinationCurrency: {
                S: body.destinationCurrency.S,
              },
              quoteId: {
                S: body.quoteId.S,
              },
            },
          }),
          DetailType: 'message',
          EventBusName: 'fx-payment-event-bus',
          Source: 'fx-payment-processing-app',
        },
      ],
    };

    console.log(
      '--- Sending update event to Event Bus ---' + JSON.stringify(sendItem)
    );
    const eventRes = await eventbridge.putEvents(sendItem).promise();
    console.log('--- Event Bus response ---' + JSON.stringify(eventRes));
  });

  await Promise.all(bulkUpdatePromises);

  return {};
};
