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




# 10. Groups

Our objective with **`groups`** 
is to enable **`people`** 
to invite others 
to ***collaborate*** 
with them.

This is a _generalised_ version
that can be used in **_any_ application**
that requires collaboration/teamwork.

## 10.1 Create Schema

Run the folloiwng 
[**`mix phx.gen.schema`**](https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Gen.Schema.html)
command to create the `groups` schema
as outlined in 
[**`#220`**](https://github.com/dwyl/auth/issues/220)

```sh
mix phx.gen.schema Group groups name:binary description:binary 
```

