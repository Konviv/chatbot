var firebase = require('../db/firebase');
var rootRef  = firebase.database().ref();

exports.isValidToken = function(token, callback) {
  firebase.auth().verifyIdToken(token).then(function(decodedToken) {
    callback(decodedToken);
  }).catch(function(error) {
    callback(null);
  });
};

exports.get = function(uid, callback) {
  firebase.auth().getUser(uid).then(function(userRecord) {
    console.log("Successfully fetched user data:", userRecord.toJSON());
    callback(userRecord);
    // See the UserRecord reference doc for the contents of userRecord.
  })
  .catch(function(error) {
    console.log("Error fetching user data:", error);
    callback(error);
    // Handle error
  });
};



exports.create = function(user, callback) {
  var usersRef = rootRef.child('users');
  usersRef.set(user, function(error) {
    if (error) {
      callback(error);
      console.log('Data could not be saved. ' + error);
    } else {
      callback('Result OK');
      console.log('Data saved successfully');
    }
  });
};
