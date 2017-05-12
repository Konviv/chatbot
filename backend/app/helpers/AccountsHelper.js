var moment      = require('moment');
var Item        = require('../models/plaid_item');
var plaidClient = require('../clients/plaid_client').Client();

exports.getAccounts = function(uid, i18n, resolve, reject) {
  Item.getAll(uid, i18n, function(items) {
    if (items.length > 0) {
      var promises = [];
      items.forEach(function(item) {
        promises.push(Item.getAccounts(plaidClient, item.access_token, item.institution.name, i18n));
      });
      Promise.all(promises).then(function(result) {
        resolve({ banks: result });
      }, function(error) {
        reject(error);
      });
    } else {
      resolve(i18n('no_banks_registered'));
    }
  }, reject);
};

exports.getLastTransaction = function(uid, i18n, resolve, reject) {
  Item.getAll(uid, i18n, function(items) {
    if (items.length > 0) {
      var params = getTransactionsParams(1);
      var promises = [];
      items.forEach(function(item) {
        promises.push(Item.getLastTransaction(plaidClient, item.access_token, item.institution.name, params));
      });
      Promise.all(promises).then(function(result) {
        result = result.filter(function(value){ return value; });
        if (result.length === 0) {
          resolve('$0');
        } else {
          result.sort(function(transactionA, transactionB) {
            return moment(transactionA.date).isBefore(moment(transactionB.date)) ? -1 : 1;
          });
          resolve('$' + result[0].amount);
        }
      }, function(error) {
        reject(error);
      });
    } else {
      resolve('$0');
    }
  }, reject);
};

exports.getAccountHistory = function(uid, accountId, i18n, resolve, reject) {
  Item.getAll(uid, i18n, function(items) {
    if (items.length > 0) {
      var params = getTransactionsParams();
      params.options.account_ids = [ accountId ];
      var promises = [];
      items.forEach(function(item) {
        promises.push(Item.getAccountHistory(plaidClient, item.access_token, item.institution.name, params, i18n));
      });
      Promise.all(promises).then(function(result) {
        result = result.filter(function(value){ return value; });
        if (result.length === 0) {
          resolve(i18n('account_history_error'));
        } else {
          resolve(result[0]);
        }
      }, function(error) {
        reject(error);
      });
    } else {
      resolve(i18n('no_banks_registered'));
    }
  }, reject);
};

exports.getAccountsTotal = function(uid, i18n, resolve, reject) {
  Item.getAll(uid, i18n, function(items) {
    if (items.length > 0) {
      var promises = [];
      items.forEach(function(item) {
        promises.push(Item.getTotalOnBank(plaidClient, item.access_token, item.institution.name, i18n));
      });
      Promise.all(promises).then(function(result) {
        resolve(result.join('\n\n'));
      }, function(error) {
        reject(error);
      });
    } else {
      resolve(i18n('no_banks_registered'));
    }
  }, reject);
};

exports.getAccountsSummary = function(uid, i18n, resolve, reject) {
  Item.getAll(uid, i18n, function(items) {
    if (items.length > 0) {
      var promises = [];
      items.forEach(function(item) {
        promises.push(Item.getAccountsBalance(plaidClient, item.access_token, item.institution.name, i18n));
      });
      Promise.all(promises).then(function(result) {
        resolve(result.join('\n\n'));
      }, function(error) {
        reject(error);
      });
    } else {
      resolve(i18n('no_banks_registered'));
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

exports.getLastAffectedAccount = function(uid, i18n, resolve, reject) {
  Item.getAll(uid, i18n, function(items) {
    if (items.length > 0) {
      var params = getTransactionsParams(1);
      var promises = [];
      items.forEach(function(item) {
        promises.push(Item.getLastAffectedAccount(plaidClient, item.access_token, item.institution.name, i18n, params));
      });
      Promise.all(promises).then(function(result) {
        resolve(result.join('\n\n'));
      }, function(error) {
        reject(error);
      });
    } else {
      resolve(i18n('no_banks_registered'));
    }
  }, reject);
};

exports.getLastTransactions = function(uid, numberOfTransactions, i18n, resolve, reject) {
  Item.getAll(uid, i18n, function(items) {
    if (items.length > 0) {
      var params = getTransactionsParams(numberOfTransactions);
      var promises = [];
      items.forEach(function(item) {
        promises.push(Item.getLastTransactions(plaidClient, item.access_token, item.institution.name, i18n, params));
      });
      Promise.all(promises).then(function(result) {
        resolve(result.join('\n\n'));
      }, function(error) {
        reject(error);
      });
    } else {
      resolve(i18n('no_banks_registered'));
    }
  }, reject);
};

exports.getSpendingAvg = function(uid, i18n, resolve, reject) {
  Item.getAll(uid, i18n, function(items) {
    if (items.length > 0) {
      var params = getTransactionsParams();
      params.days = moment().add(1, 'days').diff(moment().startOf('month'), 'days');
      var promises = [];
      items.forEach(function(item) {
        promises.push(Item.getSpendingAvg(plaidClient, item.access_token, item.institution.name, i18n, params));
      });
      Promise.all(promises).then(function(result) {
        resolve(result.join('\n\n'));
      }, function(error) {
        reject(error);
      });
    } else {
      resolve(i18n('no_banks_registered'));
    }
  }, reject);
};

exports.getFeaturedTransaction = function(uid, action, feature, i18n, resolve, reject) {
  Item.getAll(uid, i18n, function(items) {
    if (items.length > 0) {
      var params = getTransactionsParams();
      params.action  = action;
      params.feature = feature;
      var promises = [];
      items.forEach(function(item) {
        promises.push(Item.getFeaturedBill(plaidClient, item.access_token, item.institution.name, i18n, params));
      });
      Promise.all(promises).then(function(result) {
        resolve(result.join('\n\n'));
      }, function(error) {
        reject(error);
      });
    } else {
      resolve(i18n('no_banks_registered'));
    }
  }, reject);
};

exports.getAccountFunds = function(uid, accountCategories, i18n, resolve, reject) {
  Item.getAll(uid, i18n, function(items) {
    if (items.length > 0) {
      var promises = [];
      items.forEach(function(item) {
        promises.push(Item.getAccountMoney(plaidClient, item.access_token, item.institution.name, i18n, accountCategories));
      });
      Promise.all(promises).then(function(result) {
        resolve(result.join('\n\n'));
      }, function(error) {
        reject(error);
      });
    } else {
      resolve(i18n('no_banks_registered'));
    }
  }, reject);
};

exports.getExpensesOnTime = function(uid, i18n, resolve, reject, params) {
  Item.getAll(uid, i18n, function(items) {
    if (items.length > 0) {
      params.options    = {};
      params.start_date = params.dates[0];
      params.end_date   = params.dates.length === 1 ? params.dates[0] : params.dates[1];
      params.period     = getPeriodOfTime(params.start_date, params.end_date, i18n);
      delete params.dates;
      var promises = [];
      items.forEach(function(item) {
        promises.push(Item.getExpensesOnTime(plaidClient, item.access_token, item.institution.name, i18n, params));
      });
      Promise.all(promises).then(function(result) {
        resolve(result.join('\n\n'));
      }, function(error) {
        reject(error);
      });
    } else {
      resolve(i18n('no_banks_registered'));
    }
  }, reject);
};

var getPeriodOfTime = function(startDate, endDate, i18n) {
  if (startDate === endDate) {
    if (startDate === moment().format('YYYY-MM-DD')) {
      return i18n('today');
    }
    return i18n('one_day_date', moment(startDate, 'YYYY-MM-DD').format('ll'));
  } else {
    return i18n('range_date', moment(startDate, 'YYYY-MM-DD').format('ll'), moment(endDate, 'YYYY-MM-DD').format('ll'));
  }
};
