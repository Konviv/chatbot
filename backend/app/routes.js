var router = require('express').Router();

router.use('/chatbot', require('./controllers/ChatbotController'));

module.exports = router;
