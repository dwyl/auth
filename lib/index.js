/**
 * register simply creates a /register POST route
 */
exports.register = function (server, options, next) {
  // console.log(server.info)
  if(options && !options.fields) {
    var msg = 'Please define required/optional fields see: http://git.io/vctLR';
    console.log(msg)
    return next(msg);
  }
  if(options && !options.handler){
    var msg = 'Please specify a /register handler. see: http://git.io/vctLR';
    console.log(msg)
    return next(msg);
  }
  // expose /register route for any app that includes this plugin
  server.route({
      method: '*',
      path: '/register',
      config: {
        validate: {
          payload : options.fields,
          failAction: options.fail_action_handler || 'error'
        }
      },
      handler: options.handler
  });

  next(); // everything worked, continue booting the hapi server!
};

exports.register.attributes = {
    pkg: require('../package.json')
};
