
require('env2')('.env');
// console.log(process.env);
var google = require('googleapis');
var OAuth2Client = google.auth.OAuth2;
var CLIENT_ID = process.env.GOOGLE_CLIENT_ID;
var CLIENT_SECRET = process.env.GOOGLE_CLIENT_SECRET;
var REDIRECT_URL = 'http://localhost:8000/googleauth';
var oauth2Client = new OAuth2Client(CLIENT_ID, CLIENT_SECRET, REDIRECT_URL);
var plus = google.plus('v1');

/**
 * this plugin creates a /googleauth where google calls back to
 */
exports.register = function googleauth (server, options, next) {
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

  next(); // everything worked, continue booting the hapi server!
};

exports.register.attributes = {
    pkg: require('../package.json')
};
