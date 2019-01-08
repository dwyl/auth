defmodule Auth.Setup do
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
    end
  )
end
