# Hapi Login

A ***Complete Login Solution*** for **Hapi.js** Apps/APIs to get you
***up and running*** in the next ***5 minutes***.

[![Build Status](https://travis-ci.org/dwyl/hapi-auth.svg)](https://travis-ci.org/dwyl/hapi-auth)
[![codecov.io](https://codecov.io/github/dwyl/hapi-auth/coverage.svg?branch=master)](https://codecov.io/github/dwyl/hapi-auth?branch=master)
[![Dependency Status](https://david-dm.org/dwyl/hapi-auth.svg)](https://david-dm.org/dwyl/hapi-auth)


## Why?

Letting people login to your App/API is *essential* any time
there is personalized content/functionality to display.

We needed a *easy* way of doing Login/Authentication for our projects
that we could drop into any project and be up-and running in minutes
and thus avoid people re-inventing the wheel too often.

After much research and investigation, we decided to use a few *existing*
**Hapi** modules together to form a re-useable starter package.

## What?

Login for Hapi Apps/APIs which gives you a set of routes
and a predictable usage pattern.

### Tested

Our *objective* is to *extensively* test every aspect of this package
so that we can *rely* on the package for our *high-traffic/security* projects.

If you spot any area for improvement, please create an issue:
https://github.com/dwyl/hapi-login/issues so we can discuss!


## How? [![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/ideaq/time/issues)

As the name suggests, this plugin is built for apps built with the  [Hapi.js](https://github.com/nelsonic/learn-hapi) web framework.  
If you or *anyone* on your team are new to Hapi, we
have an **introductory tutorial**: https://github.com/nelsonic/learn-hapi

### Environment Variables?

This plugin checks for the presence of
*specific* **Environment Variables**
to enable each authentication provider.

If you are new to Environment Variables,
see: https://github.com/dwyl/learn-environment-variables


### Basic Login

If all you need is the ability to let people login to your app/website
using an email/username and password,
see: https://github.com/dwyl/hapi-login


### Google Auth

There are
[***900 Million***](http://techcrunch.com/2015/05/28/gmail-now-has-900m-active-users-75-on-mobile/) using GMail so offering people the option of logging into
your App(s) using their Google Account makes a lot of sense.

To enable Google Auth you will need to have two Environment Variables set:
```sh
GOOGLE_CLIENT_ID=YourAppsClientId.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=SuperSecret
```
To *get* these Environment Variables,
You will need to create an App on https://console.developers.google.com
and get your `CLIENT_ID` & `CLIENT_SECRET`.
We export these two variables prefixed with `GOOGLE_`
to distinguish them from other services.



### Dependencies

+ [**google-api-nodejs-client**](https://www.npmjs.com/package/googleapis) -
handles authentication with Google and access to other Google Services. [![Build Status](https://travis-ci.org/google/google-api-nodejs-client.svg?branch=master)](https://travis-ci.org/google/google-api-nodejs-client) [![Coverage Status](https://coveralls.io/repos/google/google-api-nodejs-client/badge.svg?branch=master&service=github)](https://coveralls.io/github/google/google-api-nodejs-client?branch=master) [![Dependency Status](https://david-dm.org/google/google-api-nodejs-client.svg)](https://david-dm.org/google/google-api-nodejs-client)

+ [**hapi-auth-jwt2**](https://github.com/dwyl/hapi-auth-jwt2) -
lets us track the session for people who have logged in and
identify (*authorise*) people returning to the site/app using a
[JSON Web Token](https://github.com/dwyl/learn-json-web-tokens) [![Build Status](https://travis-ci.org/dwyl/hapi-auth-jwt2.svg?branch=master)](https://travis-ci.org/dwyl/hapi-auth-jwt2) [![codecov.io](https://codecov.io/github/dwyl/hapi-auth-jwt2/coverage.svg?branch=master)](https://codecov.io/github/dwyl/hapi-auth-jwt2?branch=master) [![Dependency Status](https://david-dm.org/dwyl/hapi-auth-jwt2.svg)](https://david-dm.org/dwyl/hapi-auth-jwt2)

+ [**bell**](https://github.com/hapijs/bell) - Facebook, Twitter & LinkedIn Authentication

## Research


## Further Reading

If you want to learn more about the [**dwyl**]()
technology stack and how this module fits into it,
please see: https://github.com/dwyl/technology-stack


## Google Authentication

> visit: https://console.developers.google.com to get started

## Recommended Reading

+ Introduction to OAuth2:
https://www.digitalocean.com/community/tutorials/an-introduction-to-oauth-2
