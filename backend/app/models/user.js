var firebase = require('../db/firebase');

exports.isValidToken = function(token, callback) {
  firebase.auth().verifyIdToken(token).then(function(decodedToken) {
    callback(decodedToken);
  }).catch(function(error) {
    callback(null);
  });
};


exports.get = function(uid, callback) {
  firebase.auth().getUser(uid).then(function(userRecord) {
    callback(userRecord);
  })
  .catch(function(error) {
    console.log("Error fetching user data:", error);
    callback(error);
  });
};
