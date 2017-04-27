var util     = require('util');
var firebase = require('../db/firebase');
var usersRef = firebase.database().ref('users');

exports.getAll = function(uid, successCallback, errorCallback) {
  var itemsRef = usersRef.child(util.format('%s/items', uid));
  itemsRef.once('value', function(items) {
    var response = { items: [] };
    items.forEach(function(item) {
      response.items.push(item.val());
    });
    successCallback(response);
  }, function (error) {
    var response = {
      code: error.code,
      reason: 'Items read failed'
    };
    errorCallback(response);
  });
};

exports.getByInstitutionId = function(uid, institutionId, successCallback, errorCallback) {
  var itemsRef = usersRef.child(util.format('%s/items', uid));
  itemsRef.orderByChild('institution/id').equalTo(institutionId).limitToLast(1).on('value', function(data) {
    var response = null;
    data.forEach(function(item) {
      response = item.val();
    });
    successCallback(response);
  }, function (error) {
    var response = {
      code: error.code,
      reason: 'Read item failed'
    };
    errorCallback(response);
  });
};

exports.store = function(uid, item, successCallback, errorCallback) {
  var itemsRef = usersRef.child(util.format('%s/items', uid));
  itemsRef.push().set(item, function(error) {
    if (error) {
      errorCallback(error);
    } else {
      successCallback();
    }
  });
};

// exports.update = function(uid, institutionId, values, successCallback, errorCallback) {
//   var itemsRef = usersRef.child(util.format('%s/items', uid));
//   itemsRef.update(values, function(error) {
//     if (error) {
//       errorCallback(error);
//     } else {
//       successCallback();
//     }
//   });
// };

exports.getAccountsBalance = function(plaidClient, accessToken, institutionName) {
  return new Promise(function(resolve, reject) {
    plaidClient.getBalance(accessToken, function(error, result) {
      if (error !== null) {
        resolve(institutionName + ': No connection with the bank.\n');
      } else {
        if (result.accounts.length > 0) {
          var bankBalance = institutionName + '\n';
          result.accounts.forEach(function(account) {
            var accountName  = account.name;
            var accountMoney = account.balances.available !== null ? account.balances.available : account.balances.current;
            bankBalance = bankBalance.concat(accountName, ': $', accountMoney, '\n');
          });
          resolve(bankBalance);
        } else {
          resolve(institutionName + ': No accounts registered in this bank.\n');
        }
      }
    });
  });
};

exports.getTotalOnBank = function(plaidClient, accessToken, institutionName) {
  return new Promise(function(resolve, reject) {
    plaidClient.getBalance(accessToken, function(error, result) {
      if (error !== null) {
        resolve(institutionName + ': No connection with the bank.\n');
      } else {
        if (result.accounts.length > 0) {
          var bankTotal = 0;
          result.accounts.forEach(function(account) {
            var accountMoney = account.balances.available !== null ? account.balances.available : account.balances.current;
            bankTotal += accountMoney;
          });
          resolve('The total you have in all of your accounts in ' + institutionName + ' is: $' + bankTotal + '\n');
        } else {
          resolve(institutionName + ': No accounts registered in this bank.\n');
        }
      }
    });
  });
};
