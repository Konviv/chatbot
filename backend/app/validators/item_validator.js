exports.isAuthItemValid = function(item) {
  return item &&
         item.hasOwnProperty('public_token') && item.public_token.trim() !== '' &&
         item.hasOwnProperty('institution') &&
         item.institution.hasOwnProperty('id') && item.institution.id.trim() !== '' &&
         item.institution.hasOwnProperty('name') && item.institution.name.trim() !== '';
};
