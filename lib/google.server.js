require('env2')('.env');
// console.log(process.env);
var google = require('googleapis');
var OAuth2Client = google.auth.OAuth2;
var CLIENT_ID = process.env.GOOGLE_CLIENT_ID;
var CLIENT_SECRET = process.env.GOOGLE_CLIENT_SECRET;
var REDIRECT_URL = 'http://localhost:8000/googleauth';
var oauth2Client = new OAuth2Client(CLIENT_ID, CLIENT_SECRET, REDIRECT_URL);
var plus = google.plus('v1');

var Hapi = require('hapi');
var server = new Hapi.Server();
server.connection({
	host: '0.0.0.0',
	port: Number(process.env.PORT)
});
server.register(require('bell'), function (err) {
	server.route([
	  {
	  	method: 'GET',
	  	path: '/',
	  	handler: function(req, reply) {
				var url = oauth2Client.generateAuthUrl({
					access_type: 'offline', // will return a refresh token
					scope: 'https://www.googleapis.com/auth/plus.profile.emails.read'
					// can be a space-delimited string or an array of scopes
				});
	      reply("<a href='" + url +"'>Click to Login!</a>" );
	  	}
	  },
	  {
	    method: '*',
	    path: '/googleauth',
	    handler: require('./google_oauth_handler.js')
	  }
	]);
});

server.start(function(){ // boots your server
	console.log('Now Visit: http://localhost:'+server.info.port);
});

module.exports = server;
