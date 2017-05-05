var plaidClient = null;
var plaid       = require('plaid');
var envvar      = require('envvar');

exports.Client = function() {
  if (plaidClient === null) {
    plaidClient = new plaid.Client(
      envvar.string('PLAID_CLIENT_ID'),
      envvar.string('PLAID_SECRET'),
      envvar.string('PLAID_PUBLIC_KEY'),
      plaid.environments[envvar.string('PLAID_ENV')]
    );
  }
  return plaidClient;
};
