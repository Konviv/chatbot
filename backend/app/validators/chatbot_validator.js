exports.isValidMessage = function(message, context) {
  return context && message && message.trim().length > 0;
};
