var util     = require('util');
var firebase = require('../db/firebase');
var usersRef = firebase.database().ref('users');

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

exports.getAll = function(uid, successCallback, errorCallback) {
  var itemsRef = usersRef.child(util.format('%s/items', uid));
  itemsRef.once('value', function(result) {
    var items = [];
    result.forEach(function(item) {
      items.push(item.val());
    });
    successCallback(items);
  }, function (error) {
    errorCallback({
      code: error.code,
      reason: 'Impossible to read your bank information in this moment. Please try again later'
    });
  });
};

exports.getAccounts = function(plaidClient, accessToken, institutionName) {
  return new Promise(function(resolve, reject) {
    plaidClient.getAccounts(accessToken, function(error, result) {
      if (error !== null) {
        reject({ code: 500, reason: 'Impossible to stablish connection with the bank in this moment. Please try again later' });
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

exports.getAccountHistory = function(plaidClient, accessToken, institutionName, params) {
  return new Promise(function(resolve, reject) {
    plaidClient.getTransactions(accessToken, params.start_date, params.end_date, params.options, function(error, result) {
      if (error !== null) {
        reject({ code: 500, reason: 'Impossible to stablish connection with the bank in this moment. Please try again later' });
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

exports.getTotalOnBank = function(plaidClient, accessToken, institutionName) {
  return new Promise(function(resolve, reject) {
    plaidClient.getBalance(accessToken, function(error, result) {
      if (error !== null) {
        reject({ code: 500, reason: 'Impossible to stablish connection with the bank in this moment. Please try again later' });
      } else {
        if (result.accounts.length > 0) {
          var bankTotal = 0;
          result.accounts.forEach(function(account) {
            var accountMoney = account.balances.available !== null ? account.balances.available : account.balances.current;
            bankTotal += accountMoney;
          });
          resolve(util.format('%s\nThe total you have in all of your accounts is: $%d', institutionName, bankTotal));
        } else {
          resolve(institutionName + '\nNo accounts registered in this bank.');
        }
      }
    });
  });
};

exports.getAccountsBalance = function(plaidClient, accessToken, institutionName) {
  return new Promise(function(resolve, reject) {
    plaidClient.getBalance(accessToken, function(error, result) {
      if (error !== null) {
        reject({ code: 500, reason: 'Impossible to stablish connection with the bank in this moment. Please try again later' });
      } else {
        if (result.accounts.length > 0) {
          var summary = [];
          result.accounts.forEach(function(account) {
            var accountName  = account.name;
            var accountMoney = account.balances.available !== null ? account.balances.available : account.balances.current;
            summary.push(util.format('Your %s account has $%d in it', accountName, accountMoney));
          });
          resolve(institutionName + '\n' + summary.join(', '));
        } else {
          resolve(institutionName + '\nNo accounts registered in this bank.');
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

exports.getLastTransaction = function(plaidClient, accessToken, institutionName, params) {
  return new Promise(function(resolve, reject) {
    plaidClient.getTransactions(accessToken, params.start_date, params.end_date, params.options, function(error, result) {
      if (error !== null) {
        reject({ code: 500, reason: 'Impossible to stablish connection with the bank in this moment. Please try again later' });
      } else {
        if (result.transactions.length > 0) {
          var transaction = result.transactions[0];
          var accounts    = transformAccounts(result.accounts);
          var accountName = accounts[transaction.account_id].name;
          resolve(util.format('%s\nYour last payment was $%d from your %s account for %s.', institutionName, transaction.amount, accountName, transaction.name));
        } else {
          resolve(institutionName + '\nNo transactions registered.');
        }
      }
    });
  });
};

exports.getLastTransactions = function(plaidClient, accessToken, institutionName, params) {
  return new Promise(function(resolve, reject) {
    plaidClient.getTransactions(accessToken, params.start_date, params.end_date, params.options, function(error, result) {
      if (error !== null) {
        reject({ code: 500, reason: 'Impossible to stablish connection with the bank in this moment. Please try again later' });
      } else {
        if (result.transactions.length > 0) {
          var transactions = [];
          result.transactions.forEach(function(transaction) {
            transactions.push(util.format('$%d on %s', transaction.amount, transaction.name));
          });
          resolve(util.format('%s\nYour last %d transactions are %s.', institutionName, params.options.count, transactions.join(', ')));
        } else {
          resolve(institutionName + '\nNo transactions registered.');
        }
      }
    });
  });
};

exports.getSpendingAvg = function(plaidClient, accessToken, institutionName, params) {
  return new Promise(function(resolve, reject) {
    plaidClient.getTransactions(accessToken, params.start_date, params.end_date, params.options, function(error, result) {
      if (error !== null) {
        reject({ code: 500, reason: 'Impossible to stablish connection with the bank in this moment. Please try again later' });
      } else {
        if (result.transactions.length > 0) {
          var transactionsAmount = 0;
          result.transactions.forEach(function(transaction) {
            if (transaction.amount > 0) {
              transactionsAmount += transaction.amount;
            }
          });
          resolve(util.format('%s\nYour daily average for spending is $%d.', institutionName, (transactionsAmount / params.days)));
        } else {
          resolve(institutionName + '\nNo transactions registered.');
        }
      }
    });
  });
};

exports.getFeaturedBill = function(plaidClient, accessToken, institutionName, params) {
  return new Promise(function(resolve, reject) {
    plaidClient.getTransactions(accessToken, params.start_date, params.end_date, params.options, function(error, result) {
      if (error !== null) {
        reject({ code: 500, reason: 'Impossible to stablish connection with the bank in this moment. Please try again later' });
      } else {
        if (result.transactions.length > 0) {
          // Remove all the transactions where money is flowing into the account
          var transactions = result.transactions.filter(function(transaction) {
            return transaction.amount > 0;
          });
          if (transactions.length === 0) {
            resolve(institutionName + '\nNo bills registered.');
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
            resolve(util.format('%s\nYour %s bill this month was $%d on %s.', institutionName, params.feature, transaction.amount, transaction.name));
          }
        } else {
          resolve(institutionName + '\nNo transactions registered.');
        }
      }
    });
  });
};

exports.getAccountMoney = function(plaidClient, accessToken, institutionName, accountTypes) {
  return new Promise(function(resolve, reject) {
    plaidClient.getBalance(accessToken, function(error, result) {
      if (error !== null) {
        reject({ code: 500, reason: 'Impossible to stablish connection with the bank in this moment. Please try again later' });
      } else {
        if (result.accounts.length > 0) {
          var details = [];
          result.accounts.forEach(function(account) {
            if (accountTypes.some(function(type) { return type === account.type || type === account.subtype || account.name.toLowerCase().includes(type); })) {
              var accountMoney = account.balances.available !== null ? account.balances.available : account.balances.current;
              details.push(util.format('You have $%d in your %s account %s', accountMoney, accountTypes[0], account.name));
            }
          });
          if (details.length > 0) {
            resolve(util.format('%s\n%s.', institutionName, details.join(', ')));
          } else {
            resolve(util.format("%s\nYou don't have %s accounts in the bank.", institutionName, accountTypes[0]));
          }
        } else {
          resolve(institutionName + '\nNo accounts registered in this bank.');
        }
      }
    });
  });
};

exports.getExpensesOnTime = function(plaidClient, accessToken, institutionName, params) {
  return new Promise(function(resolve, reject) {
    plaidClient.getTransactions(accessToken, params.start_date, params.end_date, params.options, function(error, result) {
      if (error !== null) {
        reject({ code: 500, reason: 'Impossible to stablish connection with the bank in this moment. Please try again later' });
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
        var shopping = params.shoppingCategories.length === 0 ? '' : (' on ' + params.shoppingCategories[0]);
        resolve(util.format('%s\n%s, you spent $%d%s.', institutionName, params.period, amount, shopping));
      }
    });
  });
};
