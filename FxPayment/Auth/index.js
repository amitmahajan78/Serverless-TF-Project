exports.handler = async (event) => {
  console.log('Authorizer log : ' + JSON.stringify(event));
  var tmp = event.methodArn.split(':');
  var apiGatewayArnTmp = tmp[5].split('/');

  // Create wildcard resource
  var resource =
    tmp[0] +
    ':' +
    tmp[1] +
    ':' +
    tmp[2] +
    ':' +
    tmp[3] +
    ':' +
    tmp[4] +
    ':' +
    apiGatewayArnTmp[0] +
    '/*/*';

  // Use token
  if (event.authorizationToken == process.env.ENV_SECRET_TOKEN) {
    const policy = genPolicy('allow', resource);
    const principalId = 'aflaf78fd7afalnv';
    const context = {
      simpleAuth: true,
    };
    const response = {
      principalId: principalId,
      policyDocument: policy,
      context: context,
    };
    return response;
  } else {
    const policy = genPolicy('deny', resource);
    const principalId = 'aflaf78fd7afalnv';
    const context = {
      simpleAuth: true,
    };
    const response = {
      principalId: principalId,
      policyDocument: policy,
      context: context,
    };
    return response;
  }
};

function genPolicy(effect, resource) {
  const policy = {};
  policy.Version = '2012-10-17';
  policy.Statement = [];
  const stmt = {};
  stmt.Action = 'execute-api:Invoke';
  stmt.Effect = effect;
  stmt.Resource = resource;
  policy.Statement.push(stmt);
  return policy;
}
