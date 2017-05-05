var firebase = require('../db/firebase');

exports.get = function(uid, callback) {
  firebase.auth().getUser(uid).then(function(userRecord) {
    callback(userRecord);
  })
  .catch(function(error) {
    console.log("Error fetching user data:", error);
    callback(error);
  });
};
