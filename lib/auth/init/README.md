<div align="center">

# Welcome! 👋 

![why](https://user-images.githubusercontent.com/194400/150698837-4eab1188-0aae-4dfd-b9c1-56ce0d311d20.png)

</div>

The purpose of the **`Auth` Application**
is to have a complete separation of concerns between
our 
[**App**](https://github.com/dwyl/app)
and any Authentication/Authorization code
in order to: <br />

**a)** ***Simplify*** the **code** in the _main_ 
[**App**](https://github.com/dwyl/app)
because there is no "User Management"
to think about.

**b)** ***Maximize privacy/security*** of any/all **personal data**
that people using our App entrust in us
by storing it in a totally separate 
fully encrypted database.

**c)** Minimize the number of environment variables
in the main App so that _anyone_ can run it
from scratch in less than 2 minutes.


For better or worse,
minimizing the number of environment variables 
in the _main_
[**App**](https://github.com/dwyl/app)
means they have to go _somewhere_ ...
that somewhere is right _here_!

## Required Environment Variables for `Auth` App

In order to initialize the **`Auth` Application**
+ `ADMIN_EMAIL` - the email address of the person who will
administer the **`Auth` App**.
+ `AUTH_URL` - the base URL where the application will be hosted,
e.g: `"auth.dwyl.com"` (exclude the protocol)
+ `SECRET_KEY_BASE` - the secret Phoenix uses to sign and encrypt important information.
see:
https://hexdocs.pm/phoenix/deployment.html#handling-of-your-application-secrets
+ `ENCRYPTION_KEYS` - a list of one or more encryption keys
used to encrypt data in the database.
see: `.env_sample` for example.


