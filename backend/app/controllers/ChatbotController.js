var envvar             = require('envvar');
var router             = require('express').Router();
var messagesHelper     = require('../helpers/MessagesHelper');
var watsonConversation = require('watson-developer-cloud/conversation/v1');
// WATSON CONVERSTION SERVICES CONNECTION
var conversation = new watsonConversation({
  username: envvar.string('WATSON_USERNAME'),
  password: envvar.string('WATSON_PASSWORD'),
  version_date: watsonConversation.VERSION_DATE_2017_02_03
});

// SET MIDDLEWARES
router.use(require('../middlewares/firebase_auth'));

// GET ACCEPT-LANGUAGE TO SELECT THE RIGHT WORKSPACE TO USE
var requestLocale = function(acceptLanguage) {
  var regex = /[a-z]{2,}/;
  var match = regex.exec(acceptLanguage);
  return match ? match[0] : 'en';
};

router.get('/messages', function(req, res) {
  // var uid = req.params.uid;   // <- this is got by Auth
  var uid = req.query.uid;
  messagesHelper.readMessages(uid, function(data) {
    res.json(data);
  }, function(error) {
    res.status(error.code).json(error);
  });
});

router.get('/', function(req, res) {
  var locale = requestLocale(req.headers['accept-language']);
  var workspace_id = locale === 'es' ? envvar.string('WATSON_ES_WORKSPACE_ID')
                                     : envvar.string('WATSON_EN_WORKSPACE_ID');
  var message = {
    input: {},
    context: !req.body.context ? {} : req.body.context,
    workspace_id: workspace_id,
  };
  conversation.message(message, function(error, response) {
    if (error) {
      return res.json(error);
    }
    res.json({
      output: response.output.text,
      context: response.context
    });
  });
});

router.post('/', function(req, res) {
  var message = req.body.message;
  var context = req.body.context;
  if (!message || !message.trim() || !context) {
    return res.status(400).json({
      code: 400,
      reason: 'No message or context found'
    });
  }
  // STORE MESSAGE SENT
  // var uid = req.params.uid;   // <- this is got by Auth
  var uid = req.query.uid;
  messagesHelper.pushMessage(uid, message, true, function() {
    var locale = requestLocale(req.headers['accept-language']);
    var workspace_id = locale === 'es' ? envvar.string('WATSON_ES_WORKSPACE_ID')
                                       : envvar.string('WATSON_EN_WORKSPACE_ID');
    // CREATE AND SEND MESSAGE TO WATSON
    var data = {
      input: { text: message },
      context: context,
      workspace_id: workspace_id,
    };
    conversation.message(data, function(error, response) {



      if (error) {
        return res.json(error);
      }
      // Check what action is next.
      if (response.output.action === 'use_different_actions') {
        // if (response.intents.length > 0) {
        //   console.log('Detected intent: #' + response.intents[0].intent);
        // }
        // // entities works like params
        // if (response.entities.length > 0){
        //   console.log('Detected entities: @' + response.entities[0].entity + '. value ' + response.entities[0].value);
        // }
        // REDIREC TO THE RIGHT METHOD WITH ENTITIES AS PARAMS AND CONTEXT;
      } else {
        if (response.output.text.length !== 0) {
          console.log(response.output.text[0]);
        }
        return res.json({
          output: response.output.text,
          context: response.context,
        });
      }



    });
  }, function() {
    res.status(500).json({
      code: 500,
      reason: 'Message could not be processed.'
    });
  });
});

module.exports = router;
