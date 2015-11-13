var test = require('tape');
var nock = require('nock');
var dir  = __dirname.split('/')[__dirname.split('/').length-1];
var file = dir + __filename.replace(__dirname, '') + " > ";

var server = require('./google.server.js');



var fs = require('fs');
var token_fixture = fs.readFileSync('./test/fixtures/sample-auth-token.json');
var nock = require('nock');
var scope = nock('https://accounts.google.com')
          .post('/o/oauth2/token')
          .reply(200, token_fixture);

test(file+'Visit / root url expect to see a link', function(t) {
  var options = {
    method: "GET",
    url: "/"
  };
  server.inject(options, function(response) {
    t.equal(response.statusCode, 200, "Server is working.");
    server.stop(function(){ });
    t.end();
  });
});
