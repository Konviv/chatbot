var util     = require('util');
var firebase = require('../db/firebase');
var usersRef = firebase.database().ref('users');

exports.store = function(uid, item, i18n, callback) {
  var itemsRef = usersRef.child(util.format('%s/items', uid));
  itemsRef.push().set(item, function(error) {
    if (error) {
      callback({ code: 500, reason: i18n('bank_registration_error') });
    } else {
      callback();
    }
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

exports.getAll = function(uid, i18n, successCallback, errorCallback) {
  var itemsRef = usersRef.child(util.format('%s/items', uid));
  itemsRef.once('value', function(result) {
    var items = [];
    result.forEach(function(item) {
      items.push(item.val());
    });
    successCallback(items);
  }, function (error) {
    errorCallback({ code: 500, reason: i18n('no_bank_connection') });
  });
};

exports.getAccounts = function(plaidClient, accessToken, institutionName, i18n) {
  return new Promise(function(resolve, reject) {
    plaidClient.getAccounts(accessToken, function(error, result) {
      if (error !== null) {
        resolve({ bank_name: institutionName, accounts: i18n('no_bank_connection') });
      } else {
        var bankDetails = { bank_name: institutionName, accounts: [] };
        if (result.accounts.length > 0) {
          result.accounts.forEach(function(account) {
            bankDetails.accounts.push({ id: account.account_id, name:account.name, balances: account.balances });
          });
        }
        resolve(bankDetails);
      }
    });
  });
};

exports.getAccountHistory = function(plaidClient, accessToken, institutionName, params, i18n) {
  return new Promise(function(resolve, reject) {
    plaidClient.getTransactions(accessToken, params.start_date, params.end_date, params.options, function(error, result) {
      if (error !== null) {
        resolve(null);
      } else {
        if (result.accounts.length === 0) {
          resolve(null);
        } else {
          var transactions = [];
          var accountId = params.options.account_ids[0];
          result.transactions.forEach(function(transaction) {
            if (transaction.account_id === accountId) {
              transactions.push({ amount: transaction.amount, date: transaction.date, name: transaction.name });
            }
          });
          var accounts = transformAccounts(result.accounts);
          resolve({ bank: institutionName, account: { id: accountId, name: accounts[accountId].name, transactions: transactions }});
        }
      }
    });
  });
};

exports.getTotalOnBank = function(plaidClient, accessToken, institutionName, i18n) {
  return new Promise(function(resolve, reject) {
    plaidClient.getBalance(accessToken, function(error, result) {
      if (error !== null) {
        resolve(i18n('no_bank_data_read', institutionName));
      } else {
        if (result.accounts.length > 0) {
          var bankTotal = 0;
          result.accounts.forEach(function(account) {
            var accountMoney = account.balances.available !== null ? account.balances.available : account.balances.current;
            bankTotal += accountMoney;
          });
          resolve(i18n('total_in_accounts', institutionName, bankTotal));
        } else {
          resolve(i18n('no_accounts', institutionName));
        }
      }
    });
  });
};

exports.getAccountsBalance = function(plaidClient, accessToken, institutionName, i18n) {
  return new Promise(function(resolve, reject) {
    plaidClient.getBalance(accessToken, function(error, result) {
      if (error !== null) {
        resolve(i18n('no_bank_data_read', institutionName));
      } else {
        if (result.accounts.length > 0) {
          var summary = [];
          result.accounts.forEach(function(account) {
            var accountName  = account.name;
            var accountMoney = account.balances.available !== null ? account.balances.available : account.balances.current;
            summary.push(i18n('account_balance', accountName, accountMoney));
          });
          resolve(util.format('%s\n%s.', institutionName, summary.join(', ')));
        } else {
          resolve(i18n('no_accounts', institutionName));
        }
      }
    });
  });
};

var transformAccounts = function(accountsJSON) {
  var accounts = {};
  accountsJSON.forEach(function (account) {
    accounts[account.account_id] = { name: account.name,
                                     official_name: account.official_name,
                                     subtype: account.subtype,
                                     type: account.type
                                   };
  });
  return accounts;
};

exports.getLastTransaction = function(plaidClient, accessToken, institutionName, i18n, params) {
  return new Promise(function(resolve, reject) {
    plaidClient.getTransactions(accessToken, params.start_date, params.end_date, params.options, function(error, result) {
      if (error !== null) {
        resolve(i18n('no_bank_data_read', institutionName));
      } else {
        if (result.transactions.length > 0) {
          var transaction = result.transactions[0];
          var accounts    = transformAccounts(result.accounts);
          var accountName = accounts[transaction.account_id].name;
          resolve(i18n('last_payment', institutionName, transaction.amount, accountName, transaction.name));
        } else {
          resolve(i18n('no_transactions', institutionName));
        }
      }
    });
  });
};

exports.getLastTransactions = function(plaidClient, accessToken, institutionName, i18n, params) {
  return new Promise(function(resolve, reject) {
    plaidClient.getTransactions(accessToken, params.start_date, params.end_date, params.options, function(error, result) {
      if (error !== null) {
        resolve(i18n('no_bank_data_read', institutionName));
      } else {
        if (result.transactions.length > 0) {
          var transactions = [];
          result.transactions.forEach(function(transaction) {
            transactions.push(i18n('transaction_detail', transaction.amount, transaction.name));
          });
          resolve(i18n('last_transactions', institutionName, params.options.count, transactions.join(', ')));
        } else {
          resolve(i18n('no_transactions', institutionName));
        }
      }
    });
  });
};

exports.getSpendingAvg = function(plaidClient, accessToken, institutionName, i18n, params) {
  return new Promise(function(resolve, reject) {
    plaidClient.getTransactions(accessToken, params.start_date, params.end_date, params.options, function(error, result) {
      if (error !== null) {
        resolve(i18n('no_bank_data_read', institutionName));
      } else {
        if (result.transactions.length > 0) {
          var transactionsAmount = 0;
          result.transactions.forEach(function(transaction) {
            if (transaction.amount > 0) {
              transactionsAmount += transaction.amount;
            }
          });
          resolve(i18n('spending_avg', institutionName, (transactionsAmount / params.days).toFixed(2)));
        } else {
          resolve(i18n('no_transactions', institutionName));
        }
      }
    });
  });
};

exports.getFeaturedBill = function(plaidClient, accessToken, institutionName, i18n, params) {
  return new Promise(function(resolve, reject) {
    plaidClient.getTransactions(accessToken, params.start_date, params.end_date, params.options, function(error, result) {
      if (error !== null) {
        resolve(i18n('no_bank_data_read', institutionName));
      } else {
        if (result.transactions.length > 0) {
          // Remove all the transactions where money is flowing into the account
          var transactions = result.transactions.filter(function(transaction) {
            return transaction.amount > 0;
          });
          if (transactions.length === 0) {
            resolve(i18n('no_bills', institutionName));
          } else {
            // Sort transactions by amount from cheapest to most expensive
            transactions.sort(function(transactionA, transactionB) {
              return transactionA.amount - transactionB.amount;
            });
            var transaction = null;
            if (params.action === 'most_expensive_bill') {
              transaction = transactions[transactions.length - 1];
            } else {
              transaction = transactions[0];
            }
            resolve(i18n('featured_bill', institutionName, params.feature, transaction.amount, transaction.name));
          }
        } else {
          resolve(i18n('no_transactions', institutionName));
        }
      }
    });
  });
};

exports.getAccountMoney = function(plaidClient, accessToken, institutionName, i18n, accountTypes) {
  return new Promise(function(resolve, reject) {
    plaidClient.getBalance(accessToken, function(error, result) {
      if (error !== null) {
        resolve(i18n('no_bank_data_read', institutionName));
      } else {
        if (result.accounts.length > 0) {
          var details = [];
          result.accounts.forEach(function(account) {
            if (accountTypes.some(function(type) { return type === account.type || type === account.subtype || account.name.toLowerCase().includes(type); })) {
              var accountMoney = account.balances.available !== null ? account.balances.available : account.balances.current;
              details.push(i18n('money_in_account', accountMoney, accountTypes[0], account.name));
            }
          });
          if (details.length > 0) {
            resolve(util.format('%s\n%s.', institutionName, details.join(', ')));
          } else {
            resolve(i18n('no_account_type', institutionName, accountTypes[0]));
          }
        } else {
          resolve(i18n('no_accounts', institutionName));
        }
      }
    });
  });
};

exports.getExpensesOnTime = function(plaidClient, accessToken, institutionName, i18n, params) {
  return new Promise(function(resolve, reject) {
    plaidClient.getTransactions(accessToken, params.start_date, params.end_date, params.options, function(error, result) {
      if (error !== null) {
        resolve(i18n('no_bank_data_read', institutionName));
      } else {
        var amount = 0;
        if (result.transactions.length > 0) {
          // Remove all the transactions where money is flowing into the account
          var transactions = result.transactions.filter(function(transaction) {
            return transaction.amount > 0;
          });
          transactions.forEach(function(transaction) {
            if (params.shoppingCategories.length === 0 || params.shoppingCategories.some(function(category) { return transaction.name.toLowerCase().includes(category); })) {
              amount += transaction.amount;
            }
          });
        }
        var shopping = params.shoppingCategories.length === 0 ? '' : i18n('shopping_category', params.shoppingCategories[0]);
        resolve(i18n('expenses', institutionName, params.period, amount, shopping));
      }
    });
  });
};
