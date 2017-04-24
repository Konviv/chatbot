var router   = require('express').Router();
var plaid    = require('plaid');
var envvar   = require('envvar');
var user     = require('../models/user');
var bank     = require('../models/bank');
// PLAID APP CONNECTION
var plaidClient = new plaid.Client(
  envvar.string('PLAID_CLIENT_ID'),
  envvar.string('PLAID_SECRET'),
  envvar.string('PLAID_PUBLIC_KEY'),
  plaid.environments[envvar.string('PLAID_ENV')]
);
// Set Middlewares
// router.use(require('../middlewares/auth'));
router.use(require('../middlewares/cors'));

router.get('/', function(req, res) {
  user.get('HfdZMHHyVzWqIIAoKUKYksh4B592', function(user) {
    res.json(user);
  });
});


router.post('/users', function(req, res) {
  // var user = req.body.user;
  var user1 = {
    'HfdZMHHyVzWqIIAoKUKYksh4B592': {
      items: true
    }
  };
  user.create(user1, function(result) {
    res.json(result);
  });
});



/*
    ./accounts/{accout_category}/
    ./accounts/


    ./accounts/transactions
*/

module.exports = router;
