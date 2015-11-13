var test = require('tape');
var nock = require('nock');
var dir  = __dirname.split('/')[__dirname.split('/').length-1];
var file = dir + __filename.replace(__dirname, '') + " > ";

// example nock test if you're unfamiliar with it.
// nock intercepts an http request to a given resource/path
nock('https://google.com').get('/hello').reply(200, 'hello world');

test(file+'nock (mocking) example test', function(t) {
  var Wreck = require('wreck');

  Wreck.get('https://google.com/hello', function (err, res, payload) {
    var result = payload.toString();
    // console.log(' - - - - >'+result);
    t.equal(result, 'hello world', "Result is: "+result);
    t.end();
  });
});
