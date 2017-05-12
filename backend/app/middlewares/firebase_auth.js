var FirebaseAuth = require('../models/firebase_auth');

module.exports = function(req, res, next) {
  var token = req.headers.authorization;
  if (token) {
    FirebaseAuth.isValidToken(token, res.__, function(error, result) {
      if (error === null) {
        req.query.uid = result.uid;
        if (result.name) {
          req.query.display_name = result.name;
        }
        next();
      } else {
        res.status(error.code).json(error);
      }
    });
  } else {
    res.status(401).json({ code: 401, reason: res.__('token_null') });
  }
};
