var moment  = require('moment');
var Message = require('../models/message');

exports.readMessages = function(uid, successCallback, errorCallback) {
  Message.getAll(uid, successCallback, errorCallback);
};

exports.pushMessage = function (uid, message, sent_by_user, successCallback, errorCallback) {
  data = {
    message: message,
    datetime: moment().toString(),
    sent_by_user: sent_by_user
  };
  Message.store(uid, data, successCallback, errorCallback);
};
