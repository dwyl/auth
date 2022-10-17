<div align="center">

# Build Log 👩‍💻 
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/dwyl/mvp/Elixir%20CI?label=build&style=flat-square)


This is a log 
of the steps taken 
to build the **`auth`** Application. 🚀 <br />
It took us _hours_ 
to write it,
but you can 
[***speedrun***](https://en.wikipedia.org/wiki/Speedrun)
it in **20 minutes**. 🏁

</div>

# TODO: fill-in the gaps during the [Rebuild `#207`](https://github.com/dwyl/auth/issues/207)

For now I'm just adding the parts that are being added to the "old"
version of **`auth`** so that we can _easily_ re-create them in the re-build.

# ERD `before` adding `groups`

The database Entity Relationship Diagram (ERD)
had the following tables/relationships 
before we added `groups`:

![erd-before-groups](https://user-images.githubusercontent.com/194400/195663957-665e6064-32df-4366-89ed-c2dc109f79a6.png)


# 10. Groups

Our objective with **`groups`** 
is to enable **`people`** 
to invite others 
to ***collaborate***.

Our reasoning to include **`groups`**
in the **`auth`** App is that 
we _already_ store all **`people`** related
(_personally identifiable_) data
in **`auth`** therefore _grouping_ 
those **`people`** together makes logical sense.
Therefore this is a **_generalised_ implementation**
that can be used by **_any_ application**
that requires collaboration/teamwork.

## 10.1 Create Schema

Run the folloiwng 
[**`mix phx.gen.schema`**](https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Gen.Schema.html)
command to create the `groups` schema
as outlined in 
[**`#220`**](https://github.com/dwyl/auth/issues/220)

```sh
mix phx.gen.schema Group groups name:binary desc:binary kind:string
```

Both `group.name` and `group.desc` (description)
are considered personally identifiable or sensitive information
hence using the `binary` type in the `gen.schema` command.
The data for these fields will be encrypted at rest using 
[`Fields.Encrypted`](https://github.com/dwyl/fields).

## 10.2 Create `LiveView` for `groups`

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
file 
and add the following line of `HTML`:

```html
<h1 class="">Groups LiveView!</h1>
```

Finally, to make the **root layout** simpler, 
open the 
`lib/auth_web/templates/layout/live.html.heex`
file and 
update the contents of the `<body>` to:

```html
<body>
  <header>
    <section class="container">
      <h1>App Name Here</h1>
    </section>
  </header>
  <%= @inner_content %>
</body>
```

## 1.5 Update `router.ex`

Now that you've created the necessary files,
open the router
`lib/auth_web/router.ex` 
replace the default route `PageController` controller:

```elixir
get "/", PageController, :index
```

with our newly created `GroupsLive` controller:


```elixir
scope "/", AuthWeb do
  pipe_through :browser

  live "/groups", GroupsLive
end
```

Now if you refresh the page 
you should see the following:

![liveveiw-page-with-tailwind-style](https://user-images.githubusercontent.com/194400/176137805-34467c88-add2-487f-9593-931d0314df62.png)

## 1.6 Update Tests

At this point we have made a few changes 
that mean our automated test suite will no longer pass ... 
Run the tests in your command line with the following command:

```sh
mix test
```

You should see the tests fail:

```sh
..

  1) test GET / (AppWeb.PageControllerTest)
     test/app_web/controllers/page_controller_test.exs:4
     Assertion with =~ failed
     code:  assert html_response(conn, 200) =~ "Hello TailWorld!"
     left:  "<!DOCTYPE html>\n<html lang=\"en\">\n  <head>\n    <meta charset=\"utf-8\">\n    <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">\n    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
     <main class=\"container\">
     <h1 class=\"text-6xl text-center\">LiveView App Page!</h1>\n</main></div>
     </body>\n</html>"
     right: "Hello TailWorld!"
     stacktrace:
       test/app_web/controllers/page_controller_test.exs:6: (test)

Finished in 0.1 seconds (0.06s async, 0.1s sync)
3 tests, 1 failure
```

Create a new directory: `test/app_web/live`

Then create the file: 
`test/app_web/live/app_live_test.exs`

With the following content:

```elixir
defmodule AppWeb.AppLiveTest do
  use AppWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "LiveView App Page!"
  end
end
```

Save the file 
and re-run the tests: `mix test`

You should see output similar to the following:

```sh
Generated app app
The database for App.Repo has been dropped
...

Finished in 0.1 seconds (0.08s async, 0.1s sync)
3 tests, 0 failures

Randomized with seed 796477
```
