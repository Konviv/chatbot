var watsonClient       = null;
var envvar             = require('envvar');
var watsonConversation = require('watson-developer-cloud/conversation/v1');

exports.Client = function() {
  if (watsonClient === null) {
    watsonClient = new watsonConversation({
      username: envvar.string('WATSON_USERNAME'),
      password: envvar.string('WATSON_PASSWORD'),
      version_date: watsonConversation.VERSION_DATE_2017_04_21
    });
  }
  return watsonClient;
};
