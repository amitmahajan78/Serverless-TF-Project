exports.handler = async (event) => {
  console.log(event);
  const randomNum = Math.random();
  const resBody = {
    paymentId: event.Payload.paymentId,
    paymentStatus:
      event.Payload.quoteId === '1001'
        ? 'LOW_COST_TRANSFER_COMPLETED'
        : 'FAST_TRANSFER_COMPLETED',
    destinationCurrency: event.Payload.destinationCurrency,
    beneficiaryName: event.Payload.beneficiaryName,
    beneficiaryBankName: event.Payload.beneficiaryBankName,
    beneficiaryAccountNo: event.Payload.beneficiaryAccountNo,
    payeeName: event.Payload.payeeName,
    amount: event.Payload.amount,
  };

  const response = {
    statusCode: 200,
    body: resBody,
  };
  return response;
};
