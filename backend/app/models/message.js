var util     = require('util');
var firebase = require('../db/firebase');
var usersRef = firebase.database().ref('users');

exports.getAll = function(uid, i18n, successCallback, errorCallback) {
  var messagesRef = usersRef.child(util.format('%s/messages', uid));
  messagesRef.once('value', function(messages) {
    var response = { messages: [] };
    messages.forEach(function(message) {
      response.messages.push(message.val());
    });
    successCallback(response);
  }, function (error) {
    errorCallback({ code: 500, reason: i18n('fail_reading_messages') });
  });
};

exports.store = function(uid, message, i18n, successCallback, errorCallback) {
  var messagesRef = usersRef.child(util.format('%s/messages', uid));
  var newMessage = messagesRef.push().set(message, function(error) {
    if (error) {
      errorCallback({ code: 500, reason: i18n('message_not_processed') });
    } else {
      successCallback();
    }
  });
};
