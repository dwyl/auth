require('env2')('.env');
// console.log(process.env);
var Hoek = require('hoek');
var google = require('googleapis');
var OAuth2Client = google.auth.OAuth2;
var CLIENT_ID = process.env.GOOGLE_CLIENT_ID;
var CLIENT_SECRET = process.env.GOOGLE_CLIENT_SECRET;
var REDIRECT_URL = 'http://localhost:8000/googleauth';
var oauth2Client = new OAuth2Client(CLIENT_ID, CLIENT_SECRET, REDIRECT_URL);
var plus = google.plus('v1');

module.exports = function google_oauth_handler(req, reply) {
  var code = req.query.code;
  console.log(' - - - - - - - - - - - - code:');
  console.log(code);

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
