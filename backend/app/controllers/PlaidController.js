var router = require('express').Router();
var plaid  = require('plaid');
var envvar = require('envvar');
// PLAID APP CONNECTION
var plaidClient = new plaid.Client(
  envvar.string('PLAID_CLIENT_ID'),
  envvar.string('PLAID_SECRET'),
  envvar.string('PLAID_PUBLIC_KEY'),
  plaid.environments[envvar.string('PLAID_ENV')]
);

// MIDDLEWARE TO ALLOW CORS
router.use(function(req, res, next) {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
  next();
});

router.get('/', function(req, res) {
  res.json();
});


module.exports = router;
