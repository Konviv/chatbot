var router         = require('express').Router();
var plaid          = require('plaid');
var envvar         = require('envvar');
var moment         = require('moment');
var Item           = require('../models/plaid_item');
var messagesHelper = require('../helpers/MessagesHelper');
var itemValidator  = require('../validators/item_validator');
// PLAID APP CONNECTION
var plaidClient = new plaid.Client(
  envvar.string('PLAID_CLIENT_ID'),
  envvar.string('PLAID_SECRET'),
  envvar.string('PLAID_PUBLIC_KEY'),
  plaid.environments[envvar.string('PLAID_ENV')]
);

// SET MIDDLEWARES
router.use(require('../middlewares/firebase_auth'));
router.use(require('../middlewares/cors'));

// TODO. IS NECESARY TO VALIDATE IF ITEM EXISTS... UPDATE ACCESS_TOKEN AFTER CHANGE THE PUBLIC_TOKEN OR JUST IGNORE THE PROCESS?
router.post('/authenticate', function(req, res) {
  // Body validation
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
        res.status(204).json();
      }, function(error) {
        res.status(500).json({
          code: 500,
          reason: 'Item could not be stored.'
        });
      });
    }
  });
});

// TODO. CONTEXT VARIABLE MUST BE PRESENT IN THE REQ AND DELETED FROM HERE
var context = {};

var storeOutput = function(uid, output, res) {
  messagesHelper.pushMessage(uid, output, false, function() {
    res.json({ output: output, context: context });
  }, function(error) {
    res.status(500).json({ code: 500, reason: 'The transaction could not be processed in this moment. Please try again later' });
  });
};

router.get('/accounts', function(req, res) {
  var uid = req.query.uid;
  Item.getAll(uid, function(data) {
    var items = data.items;
    if (data.items.length > 0) {
      var promises = [];
      items.forEach(function(item) {
        promises.push(Item.getAccountsBalance(plaidClient, item.access_token, item.institution.name));
      });
      Promise.all(promises).then(function(result) {
        var summary = result.join('');
        storeOutput(uid, summary, res);
      });
    } else {
      var output = "You don't have banks registered in your account yet.";
      storeOutput(uid, output, res);
    }
  }, function(error) {
    res.status(500).json({
      code: 500,
      reason: 'There is no connection with the bank in this moment. Try again later'
    });
  });
});

router.get('/accounts_total', function(req, res) {
  var uid = req.query.uid;
  Item.getAll(uid, function(data) {
    var items = data.items;
    if (data.items.length > 0) {
      var promises = [];
      items.forEach(function(item) {
        promises.push(Item.getTotalOnBank(plaidClient, item.access_token, item.institution.name));
      });
      Promise.all(promises).then(function(result) {
        var bankTotal = result.join('');
        storeOutput(uid, bankTotal, res);
      });
    } else {
      var output = "You don't have banks registered in your account yet.";
      storeOutput(uid, output, res);
    }
  }, function(error) {
    res.status(500).json({
      code: 500,
      reason: 'There is no connection with the bank in this moment. Try again later'
    });
  });
});

router.get('/transactions', function(req, res) {
  var uid = req.query.uid;

  // TODO. START_DATE, END_DATE AND OPTIONS MUST COME IN THE REQ
  var startDate = moment().subtract(30, 'days').format('YYYY-MM-DD');
  var endDate = moment().format('YYYY-MM-DD');
  var options = {};

  Item.getAll(uid, function(data) {
    var items = data.items;
    if (data.items.length > 0) {
      var promises = [];
      items.forEach(function(item) {
        promises.push(Item.getTransactions(plaidClient, item.access_token, item.institution.name, startDate, endDate, options));
      });
      Promise.all(promises).then(function(result) {
        var transactions = result.join('\n');
        storeOutput(uid, transactions, res);
      });
    } else {
      var output = "You don't have banks registered in your account yet.";
      storeOutput(uid, output, res);
    }
  }, function(error) {
    res.status(500).json({
      code: 500,
      reason: 'There is no connection with the bank in this moment. Try again later'
    });
  });
});

// Item.getByInstitutionId("123456", 'ins_2', function(item) {
//   console.log(item);
// }, function(error) {
//   console.log(error);
// });

// router.post('/transactions', function(request, response, next) {
//     // Pull transactions for the Item for the last 30 days
//     var startDate = moment().subtract(30, 'days').format('YYYY-MM-DD');
//     var endDate = moment().format('YYYY-MM-DD');
//     plaidClient.getTransactions(ACCESS_TOKEN, startDate, endDate, {
//         count: 250,
//         offset: 0,
//     }, function(error, transactionsResponse) {
//         if (error !== null) {
//             console.log(JSON.stringify(error));
//             return response.json({error: error});
//         }
//         console.log('pulled ' + transactionsResponse.transactions.length + ' transactions');
//         response.json(transactionsResponse);
//     });
// });

module.exports = router;
