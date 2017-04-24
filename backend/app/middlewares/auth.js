var user = require('../models/user');

module.exports = function(req, res, next) {
  var token = req.headers.authorization;
  if (token) {
    user.isValidToken(token, function(result) {
      if (result) {
        // req.params.uid = result.uid;
        next();
      } else {
        res.status(401).json({
          code: 401,
          reason: 'Token invalid or user not found'
        }).end();
      }
    });
  } else {
    res.status(401).json({
      code: 401,
      reason: 'Token is null'
    }).end();
  }
};
