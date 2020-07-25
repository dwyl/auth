# Role Based Access Control (RBAC)

_Understand_ the fundamentals of Role Based Access Control (RBAC)
so that you can easily control who has access to what in your App.

## Why?

RBAC lets you easily manage roles and permissions in any application
and see at a glance exactly what permissions a person has.
It reduces complexity over traditional
Access Control List (ACL) based permissions systems
and helps everyone building and maintaining the app
to focus on security.

## _Who_?

This document is relevant to anyone 
that is interested in developing and _maintaining_ 
secure multi-person applications
should learn about RBAC.


## What?

The purpose of RBAC is to provide a framework
for application administrators and developers
to manage the permissions assigned to the people using the App(s).

Each role granted just enough flexibility and permissions 
to perform the tasks required for their job, 
this helps enforce the 
[principal of least privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege).

The RBAC methodology is based on a set of three principal rules 
that govern access to systems:

1. **Role Assignment**: 
Each transaction or operation can only be carried out 
if the person has assumed the appropriate role. 
An operation is defined as any action taken 
with respect to a system or network object that is protected by RBAC. 
Roles may be assigned by a separate party 
or selected by the person attempting to perform the action.

2. **Role Authorization**: 
The purpose of role authorization 
is to ensure that people can only assume a role 
for which they have been given the appropriate authorization. 
When a person assumes a role, 
they must do so with authorization from an admin.

3. **Transaction Authorization**: 
An operation can only be completed 
if the person attempting to complete the transaction 
possesses the appropriate role.


### Default Roles

We have defined the following 7 `default` roles based on our experience/research 
into RBAC systems of several of the most popular applications
including both "enterprise" (closed source) and popular open source CRM/CMS apps.

| **`id`** | **`name`** | **`desc`** | `person_id` |
| -------- | ---------- | ---------- | ----------- |
| `1` | superadmin | Can **`CREATE`** new roles. Can **`CREATE`**, **`UPDATE`** and **`DELETE`** Any content. Can **`PURGE`** deleted items. Can "ban" any user including people with "Admin" Role. | 1 |
| `2` | admin | Can **create** new roles and **assign** existing roles. Can **`CREATE`**, **`UPDATE`** and **`DELETE`** any content. Can "ban" any user except people with "admin" Role. Can see deleted content and un-delete it. Cannot _purge_ deleted. This guarantees audit-trail. | 1 | 
| `3` | moderator | Can neutrally moderate _any_ content. Can _ban_ rule-breaking `people`. Cannot **"`DELETE`"** content. | 1 |
| `4` | creator | Can **`CREATE`** content. Can **`UPDATE`** their _own_ content. Can **`DELETE`** their _own_ content. | 1 |
| `5` | commenter | Can **`COMMENT`** on content that has commenting enabled. | 1 |
| `6` | subscriber | Can **`SUBSCRIBE`** to receive updates (e.g: newsletter), but has either not verified their account or has made negative comments and is therefore _not_ allowed to comment. | 1 |
| `7` | banned | Can login and see their past content. Cannot create any new content. Can see the _reason_ for their banning (_which the Admin has to write when performing the "ban user" action. usually linked to a specific action the person performed like a particularly unacceptable comment._) | 1 | 

These roles are loosely inspired by WordPress: 
https://wordpress.org/support/article/roles-and-capabilities <br />
The **`superadmin`** and **`admin`** roles make sense:
The person who can perform "system administration" tasks like updating the schemas/code,
this is the **`superadmin`** or "**owner**" of the application. 
Typically there is only ***one*** **`superadmin`**,
this person is ultimately responsible for _everything_. 
The people who are responsible for _maintaining_ the site/app 
including the `content` and `people`
are given the **`admin`** role; 
they can see everything that is going on.

The **`admin`** role should 
We have renamed "editor" to "moderator"
because we feel this role is more _relevant_ in a multi-content setting
see: https://en.wikipedia.org/wiki/Moderator
We have also renamed "author" to "creator" 
to emphasize that creating content 
is more than just "authoring" text. 
There will be various types of content not just "posts".
We have added a "**commenter** role as an "upgrade" to **subscriber**,
to indicate that the person has the ability to _comment_ on content.
Finally, we have added the concept of a "**banned**" role
that still allows the person to login and view their _own_ content,
but they have no other privileges.


## _How_?

_Before_ creating any roles,
you will need to have a baseline schema including **`people`**
as **`person.id`** will be referenced by roles.

If you don't already have these schemas/tables,
see: https://github.com/dwyl/app-mvp-phoenix#create-schemas



### Create `Roles` and `Permissions` Schemas

Let's create the Database Schemas (Tables) 
to store our RBAC data,
starting with **`Roles`**:

```
mix phx.gen.html Ctx Role roles name:string desc:string person_id:references:people
```

Next create the permissions schema:
```
mix phx.gen.html Ctx Permission permissions name:string desc:string person_id:references:people
```

We placed the roles and permissions resources in an **`:auth`** pipeline
because we only want people with **`superadmin`** role to access them.
See: 
[`/lib/auth_web/router.ex#L41-L43`](https://github.com/dwyl/auth/blob/2a3c361e87cbe4fadbd6beda2eef989299c48a53/lib/auth_web/router.ex#L41-L42)



### Create Roles<->Permissions Associations

Next create the **`many-to-many`** relationship 
between roles and permissions.

```
mix ecto.gen.migration create_role_permissions
```

Open the file that was just created, e.g: 
[`priv/repo/migrations/20200723143204_create_role_permissions.exs`](https://github.com/dwyl/auth/blob/ef4261d09a702c4003cd84f30dabe630b47922d2/priv/repo/migrations/20200723143204_create_role_permissions.exs)

And replace the contents with:
```elixir
defmodule Auth.Repo.Migrations.CreateRolePermissions do
  use Ecto.Migration

  def change do
    create table(:role_permissions) do
      add :role_id, references(:roles, on_delete: :nothing)
      add :permission_id, references(:permissions, on_delete: :nothing)
      add :granter, references(:people, on_delete: :nothing)
  
      timestamps()
    end
  
    create unique_index(:role_permissions, [:role_id, :permission_id])
  end
end
```

### Create People<->Roles Associations

Now create the **`many-to-many`** relationship 
between **`people`** and **`roles`**:

```
mix ecto.gen.migration create_people_roles
```

Open the migration file that was just created, e.g: 
[`/Users/n/code/auth/priv/repo/migrations/20200723154847_create_people_roles.exs`](https://github.com/dwyl/auth/blob/ef4261d09a702c4003cd84f30dabe630b47922d2/priv/repo/migrations/20200723154847_create_people_roles.exs)


Replace the contents of the file with the following code:

```elixir
defmodule Auth.Repo.Migrations.CreatePeopleRoles do
  use Ecto.Migration

  def change do
    create table(:people_roles) do
      add :person_id, references(:people, on_delete: :nothing)
      add :role_id, references(:roles, on_delete: :nothing)
      add :granter, references(:people, on_delete: :nothing)
  
      timestamps()
    end
  
    create unique_index(:people_roles, [:person_id, :role_id])
  end
end
```

This is all we need in terms of database tables for now.
Run:
```
mix ecto.migrate
```
To create the tables.

The Entity Relationship Diagram (ERD) should now look like this:

[![auth-erd-with-roles-permissions](https://user-images.githubusercontent.com/194400/88439166-5c2e0e00-ce02-11ea-93ce-11c3a721cb18.png "Schema Diagram - Click to Enlarge")](https://user-images.githubusercontent.com/194400/88439166-5c2e0e00-ce02-11ea-93ce-11c3a721cb18.png)

Next we need to create a script 
that inserts the default roles and permissions
during the setup of the Auth App. 

### Setup Default Roles & Permissions








## Recommended Reading

+ https://en.wikipedia.org/wiki/Role-based_access_control
+ https://www.sumologic.com/glossary/role-based-access-control
+ https://medium.com/@adriennedomingus/role-based-access-control-rbac-permissions-vs-roles-55f1f0051468
+ https://digitalguardian.com/blog/what-role-based-access-control-rbac-examples-benefits-and-more