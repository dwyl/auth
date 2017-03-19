# Elixir |> Phoenix |> Authentication

A ***Complete Authentication Solution*** for **Phoenix** Apps/APIs
to get you ***up and running*** in the next ***5 minutes***.

[![Build Status](https://travis-ci.org/dwyl/auth.svg)](https://travis-ci.org/dwyl/auth)
[![codecov.io](https://codecov.io/github/dwyl/auth/coverage.svg?branch=master)](https://codecov.io/github/dwyl/auth?branch=master)


## Why?

Letting people login to your App/API is *essential* any time
there is personalized content/functionality to display.

We needed an *easy* way of doing Login/Authentication for our projects
that we could drop into any project and be up-and-running in _minutes_
and ***avoid*** "***re-inventing the wheel***".

After much research and investigation, we decided to use a few *existing*
**Elixir** modules together to form a re-useable "starter pack".

### What's In It For Me?

As a developer, _using_ this module you can _rest assured_ that
+ **all code** for **authentication** in _your_ app is
**nicely contained & organized** in a ***single place**.
+ all the auth-related code is ***well documented, tested & maintained***.
+ when ever there is an update in the underlying modules (_dependencies_)
they will be **updated** and throughly tested in a ***timely manner***.
+ you only have to **update _one_ thing**
and your app continues to work as expected.

## What?

Login for Elixir/Phoenix Apps/APIs which gives you a set of routes
and a predictable usage pattern.

### Auth "Strategies"

+ "***Basic***" - Username/Email and Password (_enabled by default_)
+ **GitHub** - Allow people to login with their GitHub Account using OAuth2
+ **Google** - Let people authenticate with the most popular auth system!

### _Tested_

Our *objective* is to **_extensively_ test every aspect** of this package
so that we can *rely* on it for our *high-traffic/security* projects.

If you spot _any_ area for improvement, please create an issue:
https://github.com/dwyl/auth/issues so we can discuss. (_thanks!_)

### Email Verification

Email is _still_ the _dominant_ way we communicate with people on the web.

Once the person has authenticated using their preferred method,
send them an email to verify their "account".
This acts as a "double-opt-in" and ensures that our app is _able_
to contact the person in the future
e.g: to reset a password or send an update/notification.

## How?

As the description suggests, this module is built for apps built with the
[**Phoenix**](https://github.com/dwyl/learn-phoenix-framework) web framework.  
If you or *anyone* on your team are new to Phoenix, we
have an **introductory tutorial**:
[github.com/dwyl/**learn-phoenix-framework**](https://github.com/dwyl/learn-phoenix-framework)

### 1-Minute Setup



To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).




### Environment Variables?

This plugin checks for the presence of
_specific **Environment Variables**_
to enable each authentication provider.

A provider (_endpoint_) will only work if the Environment Variable is present.

If you are new to Environment Variables,
see: https://github.com/dwyl/learn-environment-variables

### Google Auth

There were
[***900 Million***](http://techcrunch.com/2015/05/28/gmail-now-has-900m-active-users-75-on-mobile/)
people using GMail (_in 2015, the last available public statistics_)
and
[***1.4 billion active Android devices***](http://www.theverge.com/2015/9/29/9409071/google-android-stats-users-downloads-sales)
(_also 2015 stat_) which are _certainly_ higher now,
_so_ Google is ***by far*** the most popular "account" people have.

Offering people the option of logging into
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

This project builds on the _fantastic_ work done
by @hassox & @scrogson & friends
in ['ueberauth'](https://github.com/ueberauth/ueberauth)
which in turn was _inspired by_
[`omniauth`](https://github.com/omniauth/omniauth) (_ruby_).

The purpose of _this_ project is to have a more "_turnkey_" solution
rather than having the ingredients for the meal, we want the meal to be _ready_!

# tl;dr

### Why NOT Use a Service Like Auth0, Cognito, Stormpath, etc?

There are _several_ "Authentication-as-a-Service" providers
which promise to solve all your auth worries with a few clicks.
They are _fine_ for people/projects who _don't_ mind
sending personally identifiable information to a 3rd party service.
We care about privacy so we _have_ to know _exactly_ where
the login details (_Email Address, Name, etc._) of people _using_
our apps is _stored_.

If you prefer to use (_and pay for_) one of the existing services
and "not have to think about auth" then go for it!

_This_ repo/project is for people who _do_ want to think about auth,
want to _know_ where sensitive data is stored and want to
be able to extend the code if they choose to.

## Research



## Further Reading

If you want to learn more about the [**dwyl**](https://github.com/dwyl)
technology stack and how this module fits into it,
please see: https://github.com/dwyl/technology-stack


## Google Authentication

> visit: https://console.developers.google.com to get started


## Recommended Reading

+ Introduction to OAuth2:
https://www.digitalocean.com/community/tutorials/an-introduction-to-oauth-2
