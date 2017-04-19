// DEPENDENCIES
var express    = require('express');
var envvar     = require('envvar');
var dotenv     = require('dotenv');
var bodyParser = require('body-parser');
var path       = require('path');
// SERVER CONFIGURATION
dotenv.load();
var app = express();
app.set('ipaddr', envvar.string('APP_ADDRESS', '127.0.0.1'));
app.set('port', envvar.number('APP_PORT', 8000));
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, '/app/views/'));
app.use(express.static('./app/public'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use('/api/v1', require('./app/routes'));
// START THE SERVER
app.listen(app.get('port'), function() {
  console.log('Konviv server running on ' + app.get('ipaddr') + ':' + app.get('port'));
});
