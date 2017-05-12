var envvar           = require('envvar');
var router           = require('express').Router();
var watsonClient     = require('../clients/watson_client').Client();
var chatbotValidator = require('../validators/chatbot_validator');
var messagesHelper   = require('../helpers/MessagesHelper');
var accountsHelper   = require('../helpers/AccountsHelper');

// SET MIDDLEWARES
router.use(require('../middlewares/firebase_auth'));

// TODO. Incluir variable timezone en el context de Watson

// GET ACCEPT-LANGUAGE TO SELECT THE RIGHT WORKSPACE TO USE
var requestLocale = function(acceptLanguage) {
  var regex = /[a-z]{2,}/;
  var match = regex.exec(acceptLanguage);
  return match ? match[0] : 'en';
};

var storeWatsonOutput = function(uid, output, context, res) {
  messagesHelper.pushMessage(uid, output, false, res.__, function() {
    res.json({ output: output, context: context });
  }, function(error) {
    res.status(error.code).json(error);
  });
};

var bankRequest = function(uid, action, entities, workspaceId, i18n) {
  return new Promise(function(resolve, reject) {
    if (action === 'total_money') {
      accountsHelper.getAccountsTotal(uid, i18n, resolve, reject);
    } else if (action === 'accounts_summary') {
      accountsHelper.getAccountsSummary(uid, i18n, resolve, reject);
    } else if (action === 'last_affected_account') {
      accountsHelper.getLastAffectedAccount(uid, i18n, resolve, reject);
    } else if (action === 'last_transactions') {
      if (entities[0].entity === 'sys-number') {
        accountsHelper.getLastTransactions(uid, parseInt(entities[0].value), i18n, resolve, reject);
      } else {
        reject({ code: 400, reason: i18n('bad_question_format') });
      }
    } else if (action === 'spending_avg') {
      accountsHelper.getSpendingAvg(uid, i18n, resolve, reject);
    } else if (action === 'most_expensive_bill' || action === 'cheapest_bill') {
      if (entities[0].entity === 'featured_bill') {
        accountsHelper.getFeaturedTransaction(uid, action, entities[0].value, i18n, resolve, reject);
      } else {
        reject({ code: 400, reason: i18n('bad_question_format') });
      }
    } else if (action === 'account_funds') {
      if (entities[0].entity === 'account_category') {
        var accountCategories = [ entities[0].value ];
        var options = { workspace_id: workspaceId, entity: 'account_category', value: accountCategories[0] };
        watsonClient.getSynonyms(options, function(error, result) {
          if (error !== null) {
            accountsHelper.getAccountFunds(uid, accountCategories, i18n, resolve, reject);
          } else {
            result.synonyms.forEach(function(synonym) {
              accountCategories.push(synonym.synonym);
            });
            accountsHelper.getAccountFunds(uid, accountCategories, i18n, resolve, reject);
          }
        });
      } else {
        reject({ code: 400, reason: i18n('bad_question_format') });
      }
    } else if (action === 'expenses_on_time') {
      var params = { dates: [], shoppingCategories: [] };
      entities.forEach(function(entity) {
        if (entity.entity === 'sys-date') {
          params.dates.push(entity.value);
        } else if (entity.entity === 'shopping_category') {
          params.shoppingCategories.push(entity.value);
        }
      });
      if (params.dates.length === 0) {
        reject({ code: 400, reason: i18n('bad_question_format') });
      } else {
        if (params.shoppingCategories.length > 0) {
          var option = { workspace_id: workspaceId, entity: 'shopping_category', value: params.shoppingCategories[0] };
          watsonClient.getSynonyms(option, function(error, result) {
            if (error !== null) {
              accountsHelper.getExpensesOnTime(uid, i18n, resolve, reject, params);
            } else {
              result.synonyms.forEach(function(synonym) {
                params.shoppingCategories.push(synonym.synonym);
              });
              accountsHelper.getExpensesOnTime(uid, i18n, resolve, reject, params);
            }
          });
        } else {
          accountsHelper.getExpensesOnTime(uid, i18n, resolve, reject, params);
        }
      }
    }
  });
};

router.get('/messages', function(req, res) {
  var uid = req.query.uid;
  messagesHelper.readMessages(uid, res.__, function(data) {
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
      console.log(error);
      return res.status(500).json({ code: 500, reason: res.__('watson_communication_error') });
    }
    var context = response.context;
    var output  = response.output.text.join('');
    storeWatsonOutput(uid, output, context, res);
  });
});

router.post('/', function(req, res) {
  var message = req.body.message;
  if (!chatbotValidator.isValidMessage(message, req.body.context)) {
    return res.status(400).json({ code: 400, reason: res.__('invalid_message') });
  }
  var uid = req.query.uid;
  messagesHelper.pushMessage(uid, message, true, res.__, function() {
    var locale      = requestLocale(req.headers['accept-language']);
    var workspaceId = locale === 'es' ? envvar.string('WATSON_ES_WORKSPACE_ID')
                                       : envvar.string('WATSON_EN_WORKSPACE_ID');
    // CREATE AND SEND MESSAGE TO WATSON
    var data = {
      input: { text: message },
      context: getContext(req),
      workspace_id: workspaceId,
    };
    watsonClient.message(data, function(error, response) {
      if (error) {
        console.log(error);
        return res.status(500).json({ code: 500, reason: res.__('watson_communication_error') });
      }
      var context = response.context;
      var action  = response.output.action;
      if (!action) {
        storeWatsonOutput(uid, response.output.text.join(''), context, res);
      } else {
        bankRequest(uid, action, response.entities, workspaceId, res.__).then(function(result) {
          storeWatsonOutput(uid, result, context, res);
        }, function(error) {
          res.status(error.code).json(error);
        });
      }
    });
  }, function(error) {
    res.status(error.code).json(error);
  });
});

module.exports = router;
