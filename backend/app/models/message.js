var util     = require('util');
var firebase = require('../db/firebase');
var usersRef = firebase.database().ref('users');

exports.getAll = function(uid, successCallback, errorCallback) {
  var messagesRef = usersRef.child(util.format('%s/messages', uid));
  messagesRef.once('value', function(messages) {
    var response = { messages: [] };
    messages.forEach(function(message) {
      response.messages.push(message.val());
    });
    successCallback(response);
  }, function (error) {
    var response = {
      code: error.code,
      reason: 'Messages read failed'
    };
    errorCallback(response);
  });
};

exports.store = function(uid, message, successCallback, errorCallback) {
  var messagesRef = usersRef.child(util.format('%s/messages', uid));
  var newMessage = messagesRef.push().set(message, function(error) {
    if (error) {
      errorCallback(error);
    } else {
      successCallback();
    }
  });
};
