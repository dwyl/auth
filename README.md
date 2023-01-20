<div align="center">

# `auth`

A ***complete authentication solution*** for **Phoenix** Apps/APIs
you can setup in ***5 minutes***.

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/dwyl/auth/ci.yml?label=build&style=flat-square&branch=main)
[![codecov.io](https://img.shields.io/codecov/c/github/dwyl/auth/master.svg?style=flat-square)](http://codecov.io/github/dwyl/auth?branch=master)
[![Hex.pm](https://img.shields.io/hexpm/v/auth?color=brightgreen&style=flat-square)](https://hex.pm/packages/auth)
[![docs](https://img.shields.io/badge/docs-maintained-brightgreen?style=flat-square)](https://hexdocs.pm/auth/api-reference.html)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat-square)](https://github.com/dwyl/auth/issues)
[![HitCount](http://hits.dwyl.com/dwyl/auth.svg)](http://hits.dwyl.com/dwyl/auth)
<!-- uncomment when service is working ...
[![Inline docs](http://inch-ci.org/github/dwyl/auth.svg?branch=master&style=flat-square)](http://inch-ci.org/github/dwyl/auth)
[![Libraries.io dependency status](https://img.shields.io/librariesio/release/hex/auth?logoColor=brightgreen&style=flat-square)](https://libraries.io/hex/auth)
-->

</div>

## Why?

Letting people authenticate is *essential* any time
there is _personalized_ content/functionality to display.<br />
We needed an *easy* way of doing Login/Authentication for our projects
that we could drop into any project <br />
and be up-and-running in _minutes_
without worrying about complexity or maintenance.

After much research, investigation and development,
we created **`Auth`**;
a re-useable "starter pack"
for _all_ our Auth needs. <br />



### What's In It For Me?

As a developer, _using_ this App you can _rest assured_ that:

+   [x] **All code** for **authentication** in _your_ app
is **nicely contained & organized** in a ***single place***.
+   [x] An order of magnitude less code than any other auth system
and all code is ***well documented, tested & maintained***.
+   [x] Whenever there is an update in the underlying modules (_dependencies_)
we **update** and throughly tested in a ***timely manner***.
+   [x] All ***personally identifiable information*** is securely stored
in a logically separate place from your main application
so you have extra security.
+   [x] You only have to **update _one_ thing**
and your app continues to work as expected.

## What?

Login for Elixir/Phoenix Apps/APIs which gives you a set of routes
and a predictable usage pattern.

### What Can People Use to Authenticate?

+   **Email+Password** - Email and Password (_enabled by default_)
+   **GitHub** - Allow people to login with their GitHub Account using OAuth2
+   **Google** - Let people authenticate with the most popular auth system!

<!-- this section needs to be re-worded ... or removed!

### _Tested_


Our *objective* is to **_extensively_ test every aspect** of this package
so that we can *rely* on it for our *high-traffic/security* projects.

If you spot _any_ area for improvement, please create an issue:
https://github.com/dwyl/auth/issues (_thanks!_)

### Email Verification

Email is _still_ the _dominant_ way we communicate with people on the web.

Once the person has authenticated using their preferred method,
send them an email to verify their "account". <br />
This acts as a "double-opt-in" and ensures that our app is _able_
to contact the person in the future. <br />
e.g: to reset a password or send an update/notification.

#### Why Email?

We don't think "Auth" _can_ be done without _some_ form of verification. <br />
We could send SMS or "Native" Notifications but both _cost more_ than email.

-->

# How?

As the description suggests, this module is built for apps built with the
[**Phoenix**](https://github.com/dwyl/learn-phoenix-framework) web framework.  
If you or *anyone* on your team are new to Phoenix, we
have an **introductory tutorial**:
[github.com/dwyl/**learn-phoenix-framework**](https://github.com/dwyl/learn-phoenix-framework)




## 5 Minute 5 Step Setup

> **Note** the App will **_not_ compile/work** 
until you have the **required environment variables**. <br />
You will see an error similar to: 
[**issues/157**](https://github.com/dwyl/auth/issues/157).
See the 3<sup>rd</sup> step below.


### 1. Clone the project:

```sh
git clone git@github.com:dwyl/auth.git && cd auth
```

### 2. Install dependencies:

```sh
mix deps.get
```

### 3. Environment Variables

The Auth App checks for the presence of
_specific **Environment Variables**_
to enable each authentication provider.

> If you are totally new to Environment Variables,
see: [github.com/dwyl/**learn-environment-variables**](https://github.com/dwyl/learn-environment-variables)

An authentication provider (_endpoint_) will only work
if the Environment Variable(s) for that service are present.

If you want to enable a specific 3rd Party Authentication service,
simply ensure that the relevant Environment Variables are defined.


#### Google Auth

To enable Google Auth
you will need to have two Environment Variables set:
```sh
GOOGLE_CLIENT_ID=YourAppsClientId.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=SuperSecret
```
To *get* these Environment Variables,
You will need to create an App on https://console.developers.google.com
and get your `CLIENT_ID` & `CLIENT_SECRET`.

Full instructions to create your Google Auth App:
[create-google-app-guide.md](https://github.com/dwyl/elixir-auth-google/blob/master/create-google-app-guide.md)


#### GitHub Auth

Similarly, for GitHub Auth,
you will need to have these environment variables:
```sh
export GITHUB_CLIENT_ID=CreateGitHubApp
export GITHUB_CLIENT_SECRET=SuperSecret
```

Full instructions to create your GitHub App:
[create-github-app-guide.md](https://github.com/dwyl/elixir-auth-github/blob/master/create-github-app-guide.md)

#### Full List of Environment Variables

For the _full_ list of environment variables
the `Auth` App expects, see:
[`.env_sample`](https://github.com/dwyl/auth/blob/master/.env_sample)


For completing the setup of the `Auth` App,
you will need to have the `ADMIN_EMAIL`
environment variable defined. <br />
And for sending emails you will need the
`SECRET_KEY_BASE` and `EMAIL_APP_URL` defined.


### 4. Create and migrate your database:

> Ensure that PostgreSQL is running
  on your localhost before you
  run this command.

```sh
mix ecto.setup
```

### 5. Start Phoenix App

```sh
mix phoenix.server
```

**Note**: It may take a minute to compile the app the first time. ⏳

Once the Phoenix App is compiled/running,
you can visit [`localhost:4000`](http://localhost:4000) from your browser.


### 6. Check application status

Visit [`localhost:4000/init`](http://localhost:4000/init) to make sure that
all the environment variables are properly defined:

![image](https://user-images.githubusercontent.com/194400/152709372-6496b83d-4a8a-4a14-ba5f-f41645fe8c1c.png)


<br />

### Dependencies

This project builds on the _fantastic_ work done _many_
people in the Elixir/Phoenix community.


+   Phoenix default session handling
(_so your app handles sessions for authenticated users the same way
  the example apps in all the Phoenix docs_)
+   GitHub OAuth2 Authentication: <https://github.com/dwyl/elixir-auth-github>
+   Google OAuth Authentication: <https://github.com/dwyl/elixir-auth-google>


<br />

### Email + Password Registration / Login

This diagram depicts the flow:

<img width="1470" alt="registration-login-email-password-flow-diagram" src="https://user-images.githubusercontent.com/194400/81224631-e8891b80-8fdf-11ea-8e75-e3751d407b38.png">

[Edit this diagram](https://docs.google.com/presentation/d/1PUKzbRQOEgHaOmaEheU7T3AHQhRT8mhGuqVKotEJkM0/edit#slide=id.g7745f61495_0_0)



### Email

When people register with their `email` address
or authenticate with a 3rd party Authentication provider (e.g: Google),
an email is sent to the `email` address welcoming them.
The `Auth` App uses an external email service
for sending emails:
  <https://github.com/dwyl/email>

![app-services-diagram](https://user-images.githubusercontent.com/194400/77526292-41628180-6e82-11ea-8044-dacbc57ba895.png)

[Edit this diagram](https://docs.google.com/presentation/d/1PUKzbRQOEgHaOmaEheU7T3AHQhRT8mhGuqVKotEJkM0/edit#slide=id.g71eb641cbd_0_0)

The Email app provides a simplified interface for sending emails
that ensures our main App can focus on it's core functionality.

<br /> <br />

## Frequently Asked/Answered Questions

### Why NOT Use a Service Like Auth0, Cognito, Stormpath, etc?

There are _several_ "Authentication-as-a-Service" providers
which promise to solve all your auth worries with a few clicks.
They are _fine_ for people/projects who _don't_ mind
sending personally identifiable information to a 3rd party service.
We care about privacy so we _have_ to know _exactly_ where
the login details (_Email Address, Name, etc._) of people _using_
our apps is _stored_.

If you prefer to use (_and pay for_)
one of the existing
["black box"](https://en.wikipedia.org/wiki/Black_box)
services
and "not have to think about auth" then go for it!

_This_ repo/project is for people who _do_ want to think about auth,
want to _know_ where sensitive data is stored and want to
be able to extend the code if they choose to.

### Phoenix Has a Session System, Does this _Use_ It?

Phoenix has a built-in mechanism for sessions:
  <http://www.phoenixframework.org/docs/sessions>

This project _uses_ and _extends_ it to support several 3rd party auth services.

<br /><br />

### Troubleshooting

If you see the following error error 
when visiting the status (_or any other page_):
http://localhost:4000/status
![image](https://user-images.githubusercontent.com/194400/152191803-e7127118-7107-40aa-aaa7-a4618726b689.png)

You forgot to create and export the 
`SECRET_KEY_BASE`
environment variable.

Create a [secret](https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Gen.Secret.html)
by running the following command in your terminal:

```sh
mix phx.gen.secret
```

Copy the output and export it, e.g:

```sh
export SECRET_KEY_BASE=mAfe8fGd3CgpiwKCnnulAhO2RjcSxuFlw6BGjBhRJCYo2Mthtmu/cdIvO3Mz1QU8
```

Where the long string 
is whatever was generated above.
Once the 
`SECRET_KEY_BASE`
environment variable is exported
and you restart the app,
it should work as expected.



## Background Reading

If you are new to Authentication, 
we recommend checkout out these great resources

+   Auth Boss: <https://github.com/teesloane/Auth-Boss>
+   Introduction to OAuth2: <https://www.digitalocean.com/community/tutorials/an-introduction-to-oauth-2>

![wake-sleeping-heroku-app](https://dwylauth.herokuapp.com/ping)
