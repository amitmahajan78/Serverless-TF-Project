const AWS = require('aws-sdk');
const sqs = new AWS.SQS();

exports.handler = async (event, context) => {
  const awsAccountId = context.invokedFunctionArn.split(':')[4];
  const region_code = process.env.AWS_REGION;
  console.log('AccountID:  ' + awsAccountId);
  console.log('Region:  ' + region_code);
  if (
    event.Records[0].dynamodb.NewImage.paymentStatus.S === 'FxPayment Created'
  ) {
    console.log(
      'Sending SQS Message for paymentId: ' +
        event.Records[0].dynamodb.NewImage.paymentStatus.S +
        ' to : https://sqs.' +
        region_code +
        '.amazonaws.com/' +
        awsAccountId +
        '/NewFxPaymentQueue'
    );
    await sqs
      .sendMessage({
        MessageBody: JSON.stringify(event.Records[0].dynamodb.NewImage),
        QueueUrl:
          'https://sqs.' +
          region_code +
          '.amazonaws.com/' +
          awsAccountId +
          '/NewFxPaymentQueue',
      })
      .promise();
  }
};
