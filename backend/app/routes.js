var router = require('express').Router();

router.use('/chatbot', require('./controllers/ChatbotController'));
router.use('/plaid', require('./controllers/PlaidController'));

module.exports = router;
