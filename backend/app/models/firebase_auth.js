var firebase = require('../db/firebase');

exports.isValidToken = function(idToken, callback) {
  firebase.auth().verifyIdToken(idToken).then(function(decodedToken) {
    callback(decodedToken);
  }).catch(function(error) {
    callback(null);
  });
};
