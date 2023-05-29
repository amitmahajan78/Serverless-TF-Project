exports.handler = async (event, context, callback) => {
  var response = '';

  var requestBody = '';

  try {
    requestBody = JSON.parse(event.body);
  } catch (e) {
    requestBody = event.body;
  }

  console.log(requestBody);
  const lowFee = (0.14 / 100) * requestBody.amount;
  const fastFee = (0.38 / 100) * requestBody.amount;
  const responseBody = {
    message: 'Please use one of the QuoteID in your payment instructions.',
    option1:
      'QuoteID 1001 - low cost transfer for ' +
      requestBody.destinationCurrency +
      ` with fee of ${lowFee.toFixed(2)} USD`,
    option2:
      'QuoteID 1002 - fast and easy transfer for ' +
      requestBody.destinationCurrency +
      ` with fee of ${fastFee.toFixed(2)} USD`,
  };

  if (requestBody.amount > 10000 || requestBody.amount < 50) {
    response = {
      statusCode: 400,
      body: JSON.stringify({
        message:
          'Sorry, we cannot offer a quote for a transfer above $10000 or below $50',
      }),
    };
  } else {
    response = {
      statusCode: 200,
      body: JSON.stringify(responseBody),
    };
  }

  callback(null, response);
};
