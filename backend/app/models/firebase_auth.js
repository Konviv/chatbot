var firebase = require('../db/firebase');

exports.isValidToken = function(idToken, i18n, callback) {
  firebase.auth().verifyIdToken(idToken).then(function(decodedToken) {
    callback(null, decodedToken);
  }).catch(function(errorResult) {
    var reason  = '';
    var code    = errorResult.errorInfo.code;
    var message = errorResult.errorInfo.message;
    if (code === 'auth/argument-error' && message.includes('Firebase ID token has expired.')) {
      reason = i18n('token_expired');
    } else {
      reason = i18n('invalid_token');
    }
    callback({ code: 401, reason: reason }, null);
  });
};
