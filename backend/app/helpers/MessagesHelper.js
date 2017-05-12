var moment  = require('moment');
var Message = require('../models/message');

exports.readMessages = function(uid, i18n, successCallback, errorCallback) {
  Message.getAll(uid, i18n, successCallback, errorCallback);
};

exports.pushMessage = function (uid, message, sent_by_user, i18n, successCallback, errorCallback) {
  data = {
    message: message,
    datetime: moment().toString(),
    sent_by_user: sent_by_user
  };
  Message.store(uid, data, i18n, successCallback, errorCallback);
};
