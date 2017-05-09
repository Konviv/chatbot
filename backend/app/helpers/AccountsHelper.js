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

exports.getAccountHistory = function(uid, accountId, resolve, reject) {
  Item.getAll(uid, function(items) {
    if (items.length > 0) {
      var params = getTransactionsParams();
      params.options.account_ids = [ accountId ];
      var promises = [];
      items.forEach(function(item) {
        promises.push(Item.getAccountHistory(plaidClient, item.access_token, item.institution.name, params));
      });
      Promise.all(promises).then(function(result) {
        result = result.filter(function(value){ return value; });
        resolve(result[0]);
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

exports.getAccountFunds = function(uid, accountCategory, resolve, reject) {
  Item.getAll(uid, function(items) {
    if (items.length > 0) {
      var promises = [];
      items.forEach(function(item) {
        promises.push(Item.getAccountMoney(plaidClient, item.access_token, item.institution.name, accountCategory));
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

exports.getExpensesOnTime = function(uid, resolve, reject, params) {
  Item.getAll(uid, function(items) {
    if (items.length > 0) {
      params.options    = {};
      params.start_date = params.dates[0];
      params.end_date   = params.dates.length === 1 ? params.dates[0] : params.dates[1];
      params.period     = getPeriodOfTime(params.start_date, params.end_date);
      delete params.dates;
      var promises = [];
      items.forEach(function(item) {
        promises.push(Item.getExpensesOnTime(plaidClient, item.access_token, item.institution.name, params));
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

var getPeriodOfTime = function(startDate, endDate) {
  if (startDate === endDate) {
    if (startDate === moment().format('YYYY-MM-DD')) {
      return 'Today';
    }
    return 'On ' + moment(startDate, 'YYYY-MM-DD').format('ll');
  } else {
    return 'From ' + moment(startDate, 'YYYY-MM-DD').format('ll') + ' to ' + moment(endDate, 'YYYY-MM-DD').format('ll');
  }
};
