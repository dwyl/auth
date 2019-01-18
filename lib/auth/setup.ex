defmodule Auth.Setup do
  # Should run on code compilation -
  # Reads config from app and
  # sets up config for nested dependencies
  Code.compile_quoted(
    quote do
      Application.put_env(:ueberauth, Ueberauth,
        providers: [
          github: {Ueberauth.Strategy.Github, []},
          identity:
            {Ueberauth.Strategy.Identity,
             [
               callback_methods: ["POST"],
               uid_field: :email,
               nickname_field: :email
             ]}
        ]
      )

      Application.put_env(:alog, Alog,
        repo: Application.get_env(:auth, Auth) |> Keyword.get(:repo)
      )
    end
  )
end
