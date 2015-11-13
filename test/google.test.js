require('env2')('.env');
// console.log(process.env);

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
      console.log(' - - - - - - - - - - - - reply:');
      console.log(req);
      // console.log(reply);
      reply("<pre><code>" + JSON.stringify(req.headers, null, 2) +"</pre></code>" );
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
