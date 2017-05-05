var router         = require('express').Router();
var Item           = require('../models/plaid_item');
var itemValidator  = require('../validators/item_validator');
var accountsHelper = require('../helpers/AccountsHelper');
var plaidClient    = require('../clients/plaid_client').Client();

// SET MIDDLEWARES
router.use(require('../middlewares/firebase_auth'));
router.use(require('../middlewares/cors'));

// TODO. IS NECESARY TO VALIDATE IF ITEM EXISTS... UPDATE ACCESS_TOKEN AFTER CHANGE THE PUBLIC_TOKEN OR JUST IGNORE THE PROCESS?
router.post('/authenticate', function(req, res) {
  if (!itemValidator.isAuthItemValid(req.body.item)) {
    return res.status(400).json({
      code: 400,
      reason: 'No public token or institution values found'
    });
  }
  var publicToken = req.body.item.public_token;
  plaidClient.exchangePublicToken(publicToken, function(error, tokenResponse) {
    if (error !== null) {
      res.status(error.status_code).json({
        code: error.status_code,
        reason: 'Could not exchange public_token!'
      });
    } else {
      var uid = req.query.uid;
      var item = {
        access_token: tokenResponse.access_token,
        institution: {
          id: req.body.item.institution.id,
          name: req.body.item.institution.name
        }
      };
      //STORE ACCESS TOKEN AND BANK INFO
      Item.store(uid, item, function() {
        res.status(204).end();
      }, function(error) {
        res.status(500).json({
          code: 500,
          reason: 'Item could not be stored.'
        });
      });
    }
  });
});

router.get('/accounts', function(req, res) {
  var uid = req.query.uid;
  var promise = new Promise(function(resolve, reject) {
    accountsHelper.getAccounts(uid, resolve, reject);
  });
  promise.then(function(result) {
    res.json(result);
  }, function(error) {
    res.status(error.code).json(error);
  });
});

module.exports = router;
