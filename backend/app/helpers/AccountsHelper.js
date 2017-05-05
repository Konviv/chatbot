var moment      = require('moment');
var Item        = require('../models/plaid_item');
var plaidClient = require('../clients/plaid_client').Client();

exports.getAccounts = function(uid, resolve, reject) {
  Item.getAll(uid, function(items) {
    if (items.length > 0) {
      var promises = [];
      items.forEach(function(item) {
        promises.push(Item.getAccounts(plaidClient, item.access_token, item.institution.name));
      });
      Promise.all(promises).then(function(result) {
        resolve({ banks: result });
      }, function(error) {
        reject(error);
      });
    } else {
      resolve('You have not registered banks yet.');
    }
  }, reject);
};

exports.getAccountsSummary = function(uid, resolve, reject) {
  Item.getAll(uid, function(items) {
    if (items.length > 0) {
      var promises = [];
      items.forEach(function(item) {
        promises.push(Item.getAccountsBalance(plaidClient, item.access_token, item.institution.name));
      });
      Promise.all(promises).then(function(result) {
        resolve(result.join('\n\n'));
      }, function(error) {
        reject(error);
      });
    } else {
      resolve('You have not registered banks yet.');
    }
  }, reject);
};

exports.getAccountsTotal = function(uid, resolve, reject) {
  Item.getAll(uid, function(items) {
    if (items.length > 0) {
      var promises = [];
      items.forEach(function(item) {
        promises.push(Item.getTotalOnBank(plaidClient, item.access_token, item.institution.name));
      });
      Promise.all(promises).then(function(result) {
        resolve(result.join('\n\n'));
      }, function(error) {
        reject(error);
      });
    } else {
      resolve('You have not registered banks yet.');
    }
  }, reject);
};

var getTransactionsParams = function(numberOfTransactions) {
  var params = { start_date: moment().startOf('month').format('YYYY-MM-DD'),
                 end_date: moment().format('YYYY-MM-DD'),
                 options: {}
               };
  if (numberOfTransactions !== undefined) {
    params.options.count = numberOfTransactions;
  }
  return params;
};

exports.getLastAffectedAccount = function(uid, resolve, reject) {
  Item.getAll(uid, function(items) {
    if (items.length > 0) {
      var params = getTransactionsParams(1);
      var promises = [];
      items.forEach(function(item) {
        promises.push(Item.getLastTransaction(plaidClient, item.access_token, item.institution.name, params));
      });
      Promise.all(promises).then(function(result) {
        resolve(result.join('\n\n'));
      }, function(error) {
        reject(error);
      });
    } else {
      resolve('You have not registered banks yet.');
    }
  }, reject);
};

exports.getLastTransactions = function(uid, numberOfTransactions, resolve, reject) {
  Item.getAll(uid, function(items) {
    if (items.length > 0) {
      var params = getTransactionsParams(numberOfTransactions);
      var promises = [];
      items.forEach(function(item) {
        promises.push(Item.getLastTransactions(plaidClient, item.access_token, item.institution.name, params));
      });
      Promise.all(promises).then(function(result) {
        resolve(result.join('\n\n'));
      }, function(error) {
        reject(error);
      });
    } else {
      resolve('You have not registered banks yet.');
    }
  }, reject);
};

exports.getSpendingAvg = function(uid, resolve, reject) {
  Item.getAll(uid, function(items) {
    if (items.length > 0) {
      var params = getTransactionsParams();
      params.days = moment().add(1, 'days').diff(moment().startOf('month'), 'days');
      var promises = [];
      items.forEach(function(item) {
        promises.push(Item.getSpendingAvg(plaidClient, item.access_token, item.institution.name, params));
      });
      Promise.all(promises).then(function(result) {
        resolve(result.join('\n\n'));
      }, function(error) {
        reject(error);
      });
    } else {
      resolve('You have not registered banks yet.');
    }
  }, reject);
};

exports.getFeaturedTransaction = function(uid, action, feature, resolve, reject) {
  Item.getAll(uid, function(items) {
    if (items.length > 0) {
      var params = getTransactionsParams();
      params.action  = action;
      params.feature = feature;
      var promises = [];
      items.forEach(function(item) {
        promises.push(Item.getFeaturedBill(plaidClient, item.access_token, item.institution.name, params));
      });
      Promise.all(promises).then(function(result) {
        resolve(result.join('\n\n'));
      }, function(error) {
        reject(error);
      });
    } else {
      resolve('You have not registered banks yet.');
    }
  }, reject);
};



//     plaidClient.getTransactions(ACCESS_TOKEN, startDate, endDate, {
//         count: 250,
//         offset: 0,
//     }
