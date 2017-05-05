var envvar           = require('envvar');
var router           = require('express').Router();
var watsonClient     = require('../clients/watson_client').Client();
var chatbotValidator = require('../validators/chatbot_validator');
var messagesHelper   = require('../helpers/MessagesHelper');
var accountsHelper   = require('../helpers/AccountsHelper');

// SET MIDDLEWARES
router.use(require('../middlewares/firebase_auth'));

// GET ACCEPT-LANGUAGE TO SELECT THE RIGHT WORKSPACE TO USE
var requestLocale = function(acceptLanguage) {
  var regex = /[a-z]{2,}/;
  var match = regex.exec(acceptLanguage);
  return match ? match[0] : 'en';
};

var storeWatsonOutput = function(uid, output, context, res) {
  messagesHelper.pushMessage(uid, output, false, function() {
    res.json({ output: output, context: context });
  }, function(error) {
    res.status(500).json({ code: 500, reason: 'The transaction could not be processed in this moment. Please try again later' });
  });
};

var bankRequest = function(uid, action, entities) {
  return new Promise(function(resolve, reject) {
    if (action === 'total_money') {
      accountsHelper.getAccountsTotal(uid, resolve, reject);
    } else if (action === 'accounts_summary') {
      accountsHelper.getAccountsSummary(uid, resolve, reject);
    } else if (action === 'last_affected_account') {
      accountsHelper.getLastAffectedAccount(uid, resolve, reject);
    } else if (action === 'spending_avg') {
      accountsHelper.getSpendingAvg(uid, resolve, reject);
    } else if (action === 'last_transactions') {
      if (entities[0].entity === 'sys-number') {
        accountsHelper.getLastTransactions(uid, parseInt(entities[0].value), resolve, reject);
      } else {
        reject({ code: 400, reason: 'The question has a bad format. Please rephrase your question' });
      }
    } else if (action === 'most_expensive_bill' || action === 'cheapest_bill') {
      if (entities[0].entity === 'featured_bill') {
        accountsHelper.getFeaturedTransaction(uid, action, entities[0].value, resolve, reject);
      } else {
        reject({ code: 400, reason: 'The question has a bad format. Please rephrase your question' });
      }
    }
  });
};

router.get('/messages', function(req, res) {
  var uid = req.query.uid;
  messagesHelper.readMessages(uid, function(data) {
    res.json(data);
  }, function(error) {
    res.status(error.code).json(error);
  });
});

var getContext = function(req){
  var context = !req.body.context ? {} : req.body.context;
  // context.timezone = 'America/Costa_Rica';
  if (req.query.display_name && !context.display_name) {
    context.display_name = req.query.display_name;
  }
  return context;
};

router.post('/start', function(req, res) {
  var uid          = req.query.uid;
  var locale       = requestLocale(req.headers['accept-language']);
  var workspace_id = locale === 'es' ? envvar.string('WATSON_ES_WORKSPACE_ID')
                                     : envvar.string('WATSON_EN_WORKSPACE_ID');
  var message = {
    input: {},
    context: getContext(req),
    workspace_id: workspace_id,
  };
  watsonClient.message(message, function(error, response) {
    if (error) {
      return res.status(error.code).json({
        code: error.code,
        reason: 'Watson Conversation says: ' + error.error
      });
    }
    var context = response.context;
    var output  = response.output.text;
    storeWatsonOutput(uid, output, context, res);
  });
});

router.post('/', function(req, res) {
  var message = req.body.message;
  if (!chatbotValidator.isValidMessage(message, req.body.context)) {
    return res.status(400).json({
      code: 400,
      reason: 'No message or context found'
    });
  }
  var uid = req.query.uid;
  messagesHelper.pushMessage(uid, message, true, function() {
    var locale = requestLocale(req.headers['accept-language']);
    var workspace_id = locale === 'es' ? envvar.string('WATSON_ES_WORKSPACE_ID')
                                       : envvar.string('WATSON_EN_WORKSPACE_ID');
    // CREATE AND SEND MESSAGE TO WATSON
    var data = {
      input: { text: message },
      context: getContext(req),
      workspace_id: workspace_id,
    };
    watsonClient.message(data, function(error, response) {
      if (error) {
        return res.status(error.code).json({
          code: error.code,
          reason: 'Watson Conversation says: ' + error.error
        });
      }
      var context = response.context;
      var action  = response.output.action;
      if (!action) {
        storeWatsonOutput(uid, response.output.text, context, res);
      } else {
        bankRequest(uid, action, response.entities).then(function(result) {
          storeWatsonOutput(uid, result, context, res);
        }, function(error) {
          res.status(error.code).json(error);
        });
      }
    });
  }, function(error) {
    res.status(500).json({
      code: 500,
      reason: 'Message could not be processed.'
    });
  });
});

module.exports = router;
