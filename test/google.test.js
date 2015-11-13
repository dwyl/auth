require('env2')('.env');
// console.log(process.env);
var google = require('googleapis');
var OAuth2Client = google.auth.OAuth2;
var CLIENT_ID = process.env.CLIENT_ID;
var CLIENT_SECRET = process.env.CLIENT_SECRET;
var REDIRECT_URL = 'http://localhost:8000/auth';
var oauth2Client = new OAuth2Client(CLIENT_ID, CLIENT_SECRET, REDIRECT_URL);
var plus = google.plus('v1');
var fs = require('fs');
var token_fixture = fs.readFileSync('./test/fixtures/sample-auth-token.json');
var nock = require('nock');
var scope = nock('https://accounts.google.com')
          .post('/o/oauth2/token')
          .reply(200, token_fixture);

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
			// get the Oauth2 Token
			oauth2Client.getToken(code, function(err, tokens) {
	      console.log(' - - - - - - - - - - - - - - - - - - - tokens:');
      	console.log(JSON.stringify(tokens));
	      console.log(' \n \n');
	      // set tokens to the client
	      // TODO: tokens should be set by OAuth2 client.
	      oauth2Client.setCredentials(tokens);
				plus.people.get({ userId: 'me', auth: oauth2Client }, function(err, profile) {
					if (err) {
						console.log('An error occured', err);
						return;
					}
					console.log( JSON.stringify(profile) );
					reply("Hello " +profile.name.givenName + " You Logged in Using Goolge!");
				});
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

// https://accounts.google.com/o/oauth2/auth
/*
var google = require('googleapis');
var OAuth2 = google.auth.OAuth2;

var oauth2Client = new OAuth2(CLIENT_ID, CLIENT_SECRET, REDIRECT_URL);

// generate a url that asks permissions for Google+ and Google Calendar scopes
var scopes = [
  'https://www.googleapis.com/auth/plus.me',
  'https://www.googleapis.com/auth/calendar'
];

var url = oauth2Client.generateAuthUrl({
  access_type: 'offline', // 'online' (default) or 'offline' (gets refresh_token)
  scope: scopes // If you only need one scope you can pass it as string
});
*/
