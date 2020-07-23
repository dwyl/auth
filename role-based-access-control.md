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


## What?

The purpose of RBAC is to provide a framework
for application administrators and developers
to manage the permissions assigned to the people using the App(s).

Each role granted just enough flexibility and permissions 
to perform the tasks required for their job, 
this helps enforce the 
[principal of least privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege)

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
they must do so with authorization from an administrator.

3. **Transaction Authorization**: 
An operation can only be completed 
if the person attempting to complete the transaction 
possesses the appropriate role.


## Who?

Anyone who is interested in developing secure multi-user applications
should learn about RBAC.


## _How_?

_Before_ creating any roles,
you will need to have a baseline schema including **`people`**
as **`person.id`** will be referenced by roles.

If you don't already have these schemas/tables,
see: https://github.com/dwyl/app-mvp-phoenix#create-schemas


Let's create the Database Schemas (Tables) to store our RBAC data,
starting with **`Roles`**:

```
mix phx.gen.html Ctx Role roles name:string desc:string person_id:references:people
```

Next create the permissions schema:
```
mix phx.gen.html Ctx Permission permissions name:string desc:string person_id:references:people
```

Next create the **`many-to-many`** relationship between roles and permissions.

```
mix ecto.gen.migration create_role_permissions
```



Now create the **`many-to-many`** relationship between people and roles:

```
mix ecto.gen.migration create_people_roles
```




## Recommended Reading

+ https://en.wikipedia.org/wiki/Role-based_access_control
+ https://www.sumologic.com/glossary/role-based-access-control
+ https://medium.com/@adriennedomingus/role-based-access-control-rbac-permissions-vs-roles-55f1f0051468
