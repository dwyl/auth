defmodule Auth.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :auth

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end

    # Run Seeds in Prod: https://github.com/dwyl/auth/issues/172#issuecomment-1005194147
    IO.inspect(File.cwd!(), label: "cwd")
    IO.inspect(File.ls!(File.cwd!()), label: "File.ls!(cwd)")
    IO.inspect(__ENV__.file, label: "__ENV__.file")
    filepath = "/app/auth/priv/repo/seeds.exs"
    IO.inspect(File.exists?(filepath), label: "File.exists?(filepath)")

    # relative_to = Path.relative_to(filepath, "/")
    # IO.inspect(relative_to, label: "relative_to")
    # IO.inspect(File.exists?(relative_to))

    IO.inspect(File.ls!("/"), label: "File.ls!(/)")
    IO.inspect(File.ls!("/app"), label: "File.ls!(/app)")
    IO.puts(" - - - - - - - - - - - - - - - - - - - - - - - ")
    IO.inspect(File.ls!("/app/lib"), label: "File.ls!(/app/lib)")
    IO.inspect(File.ls!("/app/lib/auth-1.6.5"), label: "File.ls!(/app/lib/auth-1.6.5)")
    # wildcard = "/app/lib/auth-*"
    # found = Path.wildcard(wildcard)
    # IO.inspect(found, label: "found")

    IO.puts(" - - - - - - - - - - - - - - - - - - - - - - - ")
    IO.inspect(File.ls!("/app/bin"), label: "File.ls!(/app/bin)")
    IO.inspect(File.exists?("/app/bin/auth"))
    # IO.inspect(File.ls!("/app/bin/auth"), label: "File.ls!(/app/bin/auth)")
    IO.puts(" - - - - - - - - - - - - - - - - - - - - - - - ")
    # IO.puts("Code.eval_file: #{filepath}")
    # Code.eval_file(filepath)
    # IO.inspect(System.get_env("AUTH_API_KEY"), label: "AUTH_API_KEY")
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
