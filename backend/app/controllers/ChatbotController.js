var envvar             = require('envvar');
var router             = require('express').Router();
var watsonConversation = require('watson-developer-cloud/conversation/v1');
// WATSON CONVERSTION SERVICES CONNECTION
var conversation = new watsonConversation({
  username: envvar.string('WATSON_USERNAME'),
  password: envvar.string('WATSON_PASSWORD'),
  version_date: watsonConversation.VERSION_DATE_2017_02_03
});

// GET ACCEPT-LANGUAGE TO SELECT THE RIGHT WORKSPACE TO USE
var requestLocale = function(acceptLanguage) {
  var regex = /[a-z]{2,}/;
  var match = regex.exec(acceptLanguage);
  return match ? match[0] : 'en';
};

router.get('/', function(req, res) {


  //****************************************************************************
  //!!!!! GET ALL MESSAGES LIST AND AFTER IT, START WATSON CONVERSATION   !!!!!!
  //****************************************************************************

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
  if (!req.body.message) {
    return res.status(400).json({
      code: 400,
      reason: 'No message found'
    });
  }
  var locale = requestLocale(req.headers['accept-language']);
  var workspace_id = locale === 'es' ? envvar.string('WATSON_ES_WORKSPACE_ID')
                                     : envvar.string('WATSON_EN_WORKSPACE_ID');
  // CREATE AND SEND MESSAGE TO WATSON
  var message = {
    input: !req.body.message ? {} : { text: req.body.message },
    context: !req.body.context ? {} : req.body.context,
    workspace_id: workspace_id,
  };
  conversation.message(message, function(error, response) {
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
});

module.exports = router;
