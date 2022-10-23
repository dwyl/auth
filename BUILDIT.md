<div align="center">

# Build Log 👩‍💻 
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/dwyl/mvp/Elixir%20CI?label=build&style=flat-square)


This is a log 
of the steps taken 
to build the **`auth`** Application. 🚀 <br />
It took us _weeks_ 
to write it,
but you can 
[***speedrun***](https://en.wikipedia.org/wiki/Speedrun)
it in **30 minutes**. 🏁

</div>

- [Build Log 👩‍💻](#build-log-)
- [TODO](#todo)
- [1. Setup the `auth` App](#1-setup-the-auth-app)
  - [1.2 Add Tailwind](#12-add-tailwind)
  - [1.6 `Petal.build` Components](#16-petalbuild-components)
  - [1.7 `mix format`](#17-mix-format)
- [ERD _`before`_ adding `groups`](#erd-before-adding-groups)
- [10. Groups](#10-groups)
  - [10.1 Create `groups` Schema](#101-create-groups-schema)
  - [10.2 _Test_ `groups` Schema](#102-test-groups-schema)
  - [10.3 Create `LiveView` for `groups`](#103-create-liveview-for-groups)
  - [10.4 Update `router.ex`](#104-update-routerex)
  - [10.5 Create `groups_live_test.exs`](#105-create-groups_live_testexs)
  - [10.6 Group _People_](#106-group-people)
  - [10.7 _Test_ `group_people.ex`](#107-test-group_peopleex)
  - [10.8 Make `group_people_test.exs` pass](#108-make-group_people_testexs-pass)

<br />

# TODO

We will fill-in the gaps during the 
[`mix phx.gen.auth` rebuild **`#207`**](https://github.com/dwyl/auth/issues/207)

For now I'm just adding the parts that are being added to the "old"
version of **`auth`** so that we can _easily_ re-create them in the re-build.


# 1. Setup the `auth` App

## 1.2 Add Tailwind

Follow the instructions in:
https://github.com/dwyl/learn-tailwind#part-2-tailwind-in-phoenix


## 1.6 `Petal.build` Components

https://petal.build/components/

## 1.7 `mix format`

See: https://github.com/dwyl/mvp/issues/183


<hr />





<hr />


# ERD _`before`_ adding `groups`

The database Entity Relationship Diagram (ERD)
had the following tables/relationships 
_before_ we added `groups`:

![erd-before-groups](https://user-images.githubusercontent.com/194400/195663957-665e6064-32df-4366-89ed-c2dc109f79a6.png)



# 10. Groups

Our objective with **`groups`** 
is to enable **`people`** 
to invite others 
to ***collaborate***.

Our reasoning to include **`groups`**
in the **`auth`** App 
is that it _already_ stores all **`people`** related
(_personally identifiable_) data,
therefore _grouping_ 
those **`people`** together makes logical sense.

This is a **_generalised_ implementation**
that can be used by **_any_ application**
that requires collaboration/teamwork.

> **Note**: we are fully aware 
> that having **`people`** and **`groups`**
> in the **`auth`** App presents
> both a _technical_ and UX/UI challenge.
> It would be _much_ simpler from the _individual_
> App's perspective to store `people` and `groups`
> in the App's DB 
> and _not_ have to connect to another App
> to retrieve and manage them.
> Luckily (for us) there is a **_widely_ accepted/practiced**
> application architecture called
> [***Microservices***](https://en.wikipedia.org/wiki/Microservices)
> where this approach to logical
> [**separation of concerns**](https://en.wikipedia.org/wiki/Separation_of_concerns)
> is ***embraced***.
> We _know_ this _initially_ introduces some complexity into our App architecture.
> But we hope that by reading on you will see that it 
> **_significantly_ simplifies** the "consuming" app.

## 10.1 Create `groups` Schema

First we need to create a new schema for storing the data.

Run the folloiwng 
[**`mix phx.gen.schema`**](https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Gen.Schema.html)
command to create the `groups` schema
as outlined in 
[**`#220`**](https://github.com/dwyl/auth/issues/220)

```sh
mix phx.gen.schema Group groups name:binary desc:binary kind:integer 
```

Both `group.name` and `group.desc` (description)
are considered personally identifiable or sensitive information
hence using the `binary` type in the `gen.schema` command.
The data for these fields will be encrypted at rest using 
[`Fields.Encrypted`](https://github.com/dwyl/fields).

The `group.kind` will be the way people _categorise_ 
their various groups. It will be an `Enum` 
and therefore the `integer` will be stored in the DB.


## 10.2 _Test_ `groups` Schema

Having created the `groups` schema & migration 
in the previous step,
a new file was created: 
`lib/auth/group.ex`

If we run the coverage report with the command: `mix c`

We see that there are 
**no tests** for the code in the `group.ex` file:

```sh
----------------
COV    FILE                                        LINES RELEVANT   MISSED
100.0% lib/auth.ex                                     9        0        0
  0.0% lib/auth/group.ex                              19        2        2   <-- This!
100.0% lib/auth/init/init.ex                         124       26        0
 ...etc...
[TOTAL]  99.3%
----------------
```

That's what we are fixing now.

Create a new file with the path:
`test/auth/group_test.exs`

Add the following code:

```elixir
defmodule Auth.GroupTest do
  use Auth.DataCase, async: true

  describe "Group Schema Tests" do
    test "Auth.Group.create/1 creates a new group" do
      group = %{
        desc: "My test group",
        name: "TestGroup",
        kind: 1
      }
      assert {:ok, inserted_group} = Auth.Group.create(group)
      assert inserted_group.name == group.name
    end
  end
end
```

Invoke this test:

```sh
mix test test/auth/group_test.exs
```

Watch it _fail_. 
That's because the 
`Auth.Group.create/1` 
does not yet _exist_.
Crete it in the 
`lib/auth/group.ex`
file:

```elixir
  @doc """
  Creates a `group`.
  """
  def create(attrs) do
    %Group{}
    |> changeset(attrs)
    |> Repo.insert()
  end
```

Rememer to add the following aliases to the top of the file:
```elixir
  alias Auth.{Repo}
  alias __MODULE__
```
That will give us access to the `Repo.insert/1` function
and `alias __MODULE__` just means 
"alias the _current_ file so that I can use it below".
e.g: `%Group{}` the schema defined in this file.

When you re-run the test:

```sh
mix test test/auth/group_test.exs
```

It should pass.

If you re-run the tests with coverage:

```sh
mix c
```

You should see the coverage back up to 100%:

```sh
----------------
COV    FILE                                        LINES RELEVANT   MISSED
100.0% lib/auth.ex                                     9        0        0
100.0% lib/auth/group.ex                              31        3        0 <-- 100%
100.0% lib/auth/init/init.ex                         124       26        0
... etc.
[TOTAL] 100.0%
----------------
```

There is still another schema 
we need to create for `groups`,
namely `group_members` 
that will allow us to add `people` to a `group`.
But let's build some UI _first_
so that we can _see_ it coming to life!

## 10.3 Create `LiveView` for `groups`

Create the `lib/auth_web/live` directory
and the controller at `lib/auth_web/live/groups_live.ex`:

```elixir
defmodule AuthWeb.GroupsLive do
  use AuthWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
```

Create the `lib/auth_web/views/groups_view.ex` file:

```elixir
defmodule AuthWeb.GroupsLiveView do
  use AuthWeb, :view
end
```

Next, create the
**`lib/auth_web/live/groups_live.html.heex`**
template file 
and add the following lines of `HTML`:

```html
<h1 class="w-full text-center text-2xl text-white font-bold 
    bg-gradient-to-r from-green-400 to-blue-500 p-4">
  Groups LiveView!
</h1>
```

Finally, to make the **root layout** simpler, 
open the 
`lib/auth_web/templates/layout/live.html.heex`
file and 
update the contents to:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title><%= assigns[:page_title] || "Auth App" %></title>
    <%= csrf_meta_tag() %>
    <link rel="stylesheet" href={Routes.static_path(@socket, "/assets/app.css") } />
  </head>
  <body class="helvetica">

    <!-- LiveView Layout File -->
      <%= @inner_content %>
    <script type="text/javascript" src={ Routes.static_path(@socket, "/assets/app.js")}></script>
  </body>
</html>
```

## 10.4 Update `router.ex`

Now that the necessary files are in place,
open the router
and add a new route `/groups` 
pointing to our newly created `GroupsLive` controller:

```elixir
scope "/", AuthWeb do
  pipe_through :browser
  pipe_through :auth

  # ... existing routes ...

  live "/groups", GroupsLive # <-- New!
end
```

Once you've saved all the files,
make sure you're running the `Phoenix` App:

```sh
mix s
```
Visit:
http://localhost:4000/groups

You should see the following:

![groups-liveview](https://user-images.githubusercontent.com/194400/197360963-fedeccf7-a096-4a94-b95d-4457cae72f0b.png)

Don't worry, all of this UI will be replaced shortly.
This is just to confirm we have Tailwind and LiveView working.

## 10.5 Create `groups_live_test.exs`

Create a new directory: `test/auth_web/live`

Then create the file: 
`test/auth_web/live/groups_live_test.exs`

With the following content:

```elixir
defmodule AuthWeb.GroupsLiveTest do
  use AuthWeb.ConnCase
  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    conn = non_admin_login(conn)
    {:ok, page_live, disconnected_html} = live(conn, "/groups")
    assert disconnected_html =~ "Groups"
    assert render(page_live) =~ "Groups"
  end
end

```

Save the file 
and run the test: 

```sh
mix test test/auth_web/live/groups_live_test.exs
```

You should see output similar to the following:

```sh
.
Finished in 0.5 seconds (0.00s async, 0.5s sync)
1 test, 0 failures

Randomized with seed 825756
```

Similarly, if you run the entire test suite with coverage:

```sh
mix c
```

You should see something similar to:

```sh
Finished in 16.4 seconds (16.1s async, 0.3s sync)
1 property, 155 tests, 0 failures

Randomized with seed 186681
----------------
COV    FILE                                        LINES RELEVANT   MISSED
100.0% lib/auth.ex                                     9        0        0
...
100.0% lib/auth/group.ex                              31        3        0
...
100.0% lib/auth_web/live/groups_live.ex                7        1        0
...
100.0% lib/auth_web/router.ex                        106       26        0
...
[TOTAL] 100.0%
----------------
```

**Note**: the `...` is just removing excess lines for brevity.


## 10.6 Group _People_

Now that we have **`groups`**,
we need a way to add **`people`** (members)
to those **`groups`**.

Run the following command in your terminal:

```sh
mix phx.gen.schema GroupPeople group_people group_id:references:groups people_role_id:references:people_roles
```

That will create two files:

`lib/auth/group_people.ex` 
(schema)
and 
`priv/repo/migrations/20221021213907_create_group_people.exs` 
(migration)

For reference, this is the schema that is created:

```elixir
defmodule Auth.GroupPeople do
  use Ecto.Schema
  import Ecto.Changeset

  schema "group_people" do

    field :group_id, :id
    field :people_role_id, :id

    timestamps()
  end

  @doc false
  def changeset(group_people, attrs) do
    group_people
    |> cast(attrs, [:group_id, :people_role_id])
    |> validate_required([])
  end
end
```

This schema is _enough_ for us to achieve _everything_ we need/want.
By leveraging the previously created `roles` and `people_roles`
tables we have a built-in full-featured 
[**`RBAC`**](https://github.com/dwyl/auth/blob/main/role-based-access-control.md)
for **`groups`**.

> **Note**: If anything is unclear, 
please keep reading for answers.
The UI/UX below will show how simple yet powerful this schema is.
But as always,
if anything is _still_ uncertain
[***please ask questions***](https://github.com/dwyl/auth/issues/)
they **benefit _everyone_**! 🙏

The `...create_group_people.exs` migration:

```elixir
defmodule Auth.Repo.Migrations.CreateGroupPeople do
  use Ecto.Migration

  def change do
    create table(:group_people) do
      add :group_id, references(:groups, on_delete: :nothing)
      add :people_role_id, references(:people_roles, on_delete: :nothing)

      timestamps()
    end

    create index(:group_people, [:group_id])
    create index(:group_people, [:people_role_id])
  end
end
```

Run the migration:

```sh
mix ecto.migrate
```

## 10.7 _Test_ `group_people.ex`

Creating the `lib/auth/group_people.ex` schema,
means it has no test coverage.

If you run:

```sh
mix c
```

You will see something similar to:

```sh
----------------
COV    FILE                                        LINES RELEVANT   MISSED
100.0% lib/auth.ex                                     9        0        0
100.0% lib/auth/group.ex                              31        3        0
  0.0% lib/auth/group_people.ex                       20        2        2
100.0% lib/auth/init/roles.ex                         69        3        0
100.0% lib/auth/people_roles.ex                      136       12        0
...etc.

[TOTAL]  99.3%
----------------
```

`lib/auth/group_people.ex` 
has **0% coverage**.
Let's _fix_ that!


Create a new file with the path:
`test/auth/group_people_test.exs`

Add the following test code:

```elixir
defmodule Auth.GroupPeopleTest do
  use Auth.DataCase, async: true

  describe "Group People Schema Tests" do
    test "Auth.GroupPeople.create/1 creates a new group" do
      # admin, app & role created by init. see: Auth.Init.main/0
      app = Auth.App.get_app!(1)
      admin = Auth.Person.get_person_by_id(1)
      role = Auth.Role.get_role!(4)

      # Create a random non-admin person we can add to the group:
      alex = %{email: "alex_not_admin@gmail.com", givenName: "Alex",
        auth_provider: "email", app_id: app.id}
      grantee = Auth.Person.create_person(alex)
      assert grantee.id > 1

      # Create group
      group = %{
        desc: "Group with people",
        name: "GroupName",
        kind: 1,
        app_id: app.id
      }
      assert {:ok, inserted_group} = Auth.Group.create(group)
      assert inserted_group.name == group.name
      assert inserted_group.app_id == app.id

      # create person_role record: (referenced in group_people)
      {:ok, person_role} = Auth.PeopleRoles.insert(app.id, grantee.id, admin.id, role.id)

      group_person = %{
        group_id: inserted_group.id,
        people_role_id: person_role.id
      }

      # Insert the GroupPerson Record
      {:ok, inserted_group_person} = Auth.GroupPeople.create(group_person)
      assert inserted_group_person.group_id == inserted_group.id
      assert inserted_group_person.people_role_id == person_role.id

      # Insert Admin Role:
      {:ok, admin_role} = Auth.PeopleRoles.insert(app.id, admin.id, admin.id, 2)

      group_person_admin = %{
        group_id: inserted_group.id,
        people_role_id: admin_role.id
      }

      # Insert the GroupPerson Admin
      {:ok, inserted_group_admin} = Auth.GroupPeople.create(group_person_admin)
      assert inserted_group_admin.group_id == inserted_group.id
      assert inserted_group_admin.people_role_id == admin_role.id

      # Finally, let's confirm these two people are in the group:
      group_people = Auth.GroupPeople.get_group_people(inserted_group.id)
      assert Enum.count(group_people) == 2
    end
  end
end
```

There's quite a lot going on here 
mostly because of the linked schemas.
Read through the steps with comments.

If you attempt to run this test:

```sh
MIX_ENV=test mix test test/auth/group_people_test.exs
```

You will see it _fail_ because the 
required functions do not exist _yet_.

Let's create the functions to make the test pass.

## 10.8 Make `group_people_test.exs` pass

Let's create the two functions:
`Auth.GroupPeople.create/1`
and 
`Auth.GroupPeople.get/1`

```elixir
  @doc """
  Creates a `group_people` record (i.e. `people` that belong to a `group`).
  """
  def create(attrs) do
    %GroupPeople{}
    |> changeset(attrs)
    |> Repo.insert()
  end


  @doc """
  `get_group_people/1` returns the list of people in a group
  """
  def get_group_people(group_id) do
    Repo.all(
      from(gp in __MODULE__,
        where: gp.group_id == ^group_id,
        join: g in Auth.Group, on: g.id == gp.group_id,
        join: pr in Auth.PeopleRoles, on: pr.id == gp.people_role_id,
        where: is_nil(pr.revoked), # don't return people that have been revoked
        join: p in Auth.Person, on: p.id == pr.person_id,
        join: r in Auth.Role, on: r.id == pr.role_id,
        select: {g.id, g.name, g.kind, pr.person_id, p.givenName, r.id, r.name, gp.inserted_at}
      )
    )
  end
```

Please note: this is not the "final" version 
of the 
`get_group_people/1`
function.
Rather it's an _initial_ implementation
that allows the test to pass.

We will be modifying it - with tests - later when
we know what we want to display in the UI/UX.


## 10.9 Create `group` & Add `people` UI/UX

Our intention with `auth` was to build 
and experience that _always_ worked for us
and did _not_ rely on `JavaScript`.
Therefore historically it has been 
**100% Server-side Rendered** 
Model View Controller (MVC).

For the `groups` UI/UX,
we want to create the look and _feel_
of a **_single_ page**
because we expect this to be
used in the context of our **Mobile-first `App`**.

