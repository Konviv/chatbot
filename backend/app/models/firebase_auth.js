var firebase = require('../db/firebase');

exports.isValidToken = function(idToken, callback) {
  firebase.auth().verifyIdToken(idToken).then(function(decodedToken) {
    callback(null, decodedToken);
  }).catch(function(errorResult) {
    var reason  = '';
    var code    = errorResult.errorInfo.code;
    var message = errorResult.errorInfo.message;
    if (code === 'auth/argument-error' && message.includes('Firebase ID token has expired.')) {
      reason = 'Firebase ID token has expired.';
    } else {
      reason = 'Invalid Firebase ID token or user not found';
    }
    callback({ code: 401, reason: reason }, null);
  });
};
