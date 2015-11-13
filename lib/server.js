require('env2')('.env');
// console.log(process.env);
var google = require('googleapis');
var OAuth2Client = google.auth.OAuth2;
var CLIENT_ID = process.env.CLIENT_ID;
var CLIENT_SECRET = process.env.CLIENT_SECRET;
var REDIRECT_URL = 'http://localhost:8000/auth';
var oauth2Client = new OAuth2Client(CLIENT_ID, CLIENT_SECRET, REDIRECT_URL);

var nock = require('nock');
var scope = nock('https://accounts.google.com')
          .post('/o/oauth2/token')
          .reply(200, { access_token: 'HELLO SIMON & ANITA!!',
						refresh_token: '123', expires_in: 10 });

var Hapi = require('hapi');
var server = new Hapi.Server();
server.connection({
	host: '0.0.0.0',
	port: Number(process.argv[2] || 8000)
});

server.route([
  {
  	method: 'GET',
  	path: '/',
  	handler: function(req, reply) {
  		return reply('Hello Hapi');
  	}
  },
  {
    method: '*',
    path: '/auth',
    handler: function(req, reply) {
      console.log(' - - - - - - - - - - - - code:');
			var code = req.query.code;
			console.log(code);
			oauth2Client.getToken(code, function(err, tokens) {
	      console.log(' - - - - - - - - - - - - - - - - - - - tokens:');
	      console.log(tokens);
	      console.log(' \n \n');
	      // set tokens to the client
	      // TODO: tokens should be set by OAuth2 client.
	      oauth2Client.setCredentials(tokens);
				reply("You Logged in Using Goolge!")
	    });
    }
  },
  {
    method: '*',
    path: '/login-page',
    handler: function(req, reply) {

			var url = oauth2Client.generateAuthUrl({
				access_type: 'offline', // will return a refresh token
				scope: 'https://www.googleapis.com/auth/plus.profile.emails.read'
				// can be a space-delimited string or an array of scopes
			});

      // console.log(reply);
      reply("<a href='" + url +"'>Click to Login!</a>" );
    }
  }
]);

server.start(function(){ // boots your server
	console.log('Now Visit: http://localhost:'+server.info.port);
});
