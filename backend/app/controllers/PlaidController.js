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
    return res.status(400).json({ code: 400, reason: res.__('invalid_plaid_auth_values') });
  }
  var publicToken = req.body.item.public_token;
  plaidClient.exchangePublicToken(publicToken, function(error, tokenResponse) {
    if (error !== null) {
      res.status(error.status_code).json({ code: error.status_code, reason: res.__('no_token_exchanged') });
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
      Item.store(uid, item, res.__, function(itemError) {
        if (itemError) {
          res.status(itemError.code).json(itemError);
        } else {
          res.status(204).end();
        }
      });
    }
  });
});

router.get('/accounts', function(req, res) {
  var uid = req.query.uid;
  var promise = new Promise(function(resolve, reject) {
    accountsHelper.getAccounts(uid, res.__, resolve, reject);
  });
  promise.then(function(result) {
    res.json(result);
  }, function(error) {
    res.status(error.code).json(error);
  });
});

router.get('/account_history/:account_id', function(req, res) {
  var accountId = req.params.account_id;
  if (!accountId) {
    res.status(400).json({ code: 400, reason: res.__('no_account_id') });
  }
  var uid = req.query.uid;
  var promise = new Promise(function(resolve, reject) {
    accountsHelper.getAccountHistory(uid, accountId, res.__, resolve, reject);
  });
  promise.then(function(result) {
    res.json(result);
  }, function(error) {
    res.status(error.code).json(error);
  });
});

module.exports = router;
