var firebase = require('../db/firebase');

exports.get = function(uid, callback) {
  firebase.auth().getUser(uid).then(function(userRecord) {
    callback(userRecord);
  })
  .catch(function(error) {
    callback(error);
  });
};
