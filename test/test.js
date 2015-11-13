var test = require('tape');
var nock = require('nock');
var dir  = __dirname.split('/')[__dirname.split('/').length-1];
var file = dir + __filename.replace(__dirname, '') + " > ";

/*
https://accounts.google.com/o/oauth2/auth?access_type=offline&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email&response_type=code&client_id=362187680368-27ov5qtji49d3skn6jtlom0l0lim4f7b.apps.googleusercontent.com&redirect_uri=http%3A%2F%2Flocalhost%3A8000%2Fauth
*/

nock('https://google.com').get('/hello').reply(200, 'whaaa');

test(file+'Basic Single String Substitution', function(t) {
  var Wreck = require('wreck');

  Wreck.get('https://google.com/hello', function (err, res, payload) {
    console.log(payload.toString());
    // t.equal();
    t.end();
  });
});
