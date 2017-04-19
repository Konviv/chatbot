var envvar             = require('envvar');
var router             = require('express').Router();
var watsonConversation = require('watson-developer-cloud/conversation/v1');
// WATSON CONVERSTION SERVICES CONNECTION
var conversation = new watsonConversation({
  username: envvar.string('WATSON_USERNAME'),
  password: envvar.string('WATSON_PASSWORD'),
  version_date: watsonConversation.VERSION_DATE_2017_02_03
});

router.post('/', function(req, res) {

  // CHANGE WORKSPACE_ID, WITH ES or EN DYNAMICALLY (USER-AGENT)
  var context = {};
  var workspace_id = envvar.string('WATSON_EN_WORKSPACE_ID');
  var message = {
    input: {},
    context: context,
    workspace_id: workspace_id,
  };

  conversation.message(message, function(error, response) {
    if (error) {
      return res.json(error);
    }

    return res.json(response);
  });
});

module.exports = router;
