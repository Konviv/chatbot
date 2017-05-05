var firebase        = require('firebase-admin');
var firebaseService = require("../../json_files/konvivappServiceAccountKey.json");

firebase.initializeApp({
  credential: firebase.credential.cert(firebaseService),
  databaseURL: "https://konvivapp.firebaseio.com"
});

module.exports = firebase;
