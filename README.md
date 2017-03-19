# Elixir |> Phoenix |> Authentication

A ***Complete Authentication Solution*** for **Phoenix** Apps/APIs
to get you ***up and running*** in the next ***5 minutes***.

[![Build Status](https://travis-ci.org/dwyl/auth.svg)](https://travis-ci.org/dwyl/auth)
[![codecov.io](https://codecov.io/github/dwyl/auth/coverage.svg?branch=master)](https://codecov.io/github/dwyl/auth?branch=master)


## Why?

Letting people login to your App/API is *essential* any time
there is personalized content/functionality to display.

We needed a *easy* way of doing Login/Authentication for our projects
that we could drop into any project and be up-and running in minutes
and thus avoid people re-inventing the wheel too often.

After much research and investigation, we decided to use a few *existing*
**Elixir** modules together to form a re-useable starter package.

## What?

Login for Elixir/Phoenix Apps/APIs which gives you a set of routes
and a predictable usage pattern.

### Tested

Our *objective* is to *extensively* test every aspect of this package
so that we can *rely* on the package for our *high-traffic/security* projects.

If you spot any area for improvement, please create an issue:
https://github.com/dwyl/auth/issues so we can discuss!


## How?

As the description suggests, this module is built for apps built with the
[**Phoenix**](https://github.com/dwyl/learn-phoenix-framework) web framework.  
If you or *anyone* on your team are new to Phoenix, we
have an **introductory tutorial**:
[github.com/dwyl/**learn-phoenix-framework**](https://github.com/dwyl/learn-phoenix-framework)

### Environment Variables?

This plugin checks for the presence of
_specific **Environment Variables**_
to enable each authentication provider.

A provider (_endpoint_) will only work if the Environment Variable is present.

If you are new to Environment Variables,
see: https://github.com/dwyl/learn-environment-variables



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

This project builds on the _fantastic_ work done by @hassox & @scrogson & pals
in https://github.com/ueberauth/ueberauth

The purpose of _this_ project is to have a more "_turnkey_" solution
rather than having the ingredients for the meal, we want the meal to be _ready_!

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
