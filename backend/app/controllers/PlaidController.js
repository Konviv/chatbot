var router   = require('express').Router();
var plaid    = require('plaid');
var envvar   = require('envvar');
// PLAID APP CONNECTION
var plaidClient = new plaid.Client(
  envvar.string('PLAID_CLIENT_ID'),
  envvar.string('PLAID_SECRET'),
  envvar.string('PLAID_PUBLIC_KEY'),
  plaid.environments[envvar.string('PLAID_ENV')]
);
// SET MIDDLEWARES
// router.use(require('../middlewares/auth'));
router.use(require('../middlewares/cors'));


/*
    ./accounts/{accout_category}/
    ./accounts/


    ./accounts/transactions
*/



module.exports = router;
