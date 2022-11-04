defmodule Auth.InitPeople do

  def sample_people do
    [
      %{
        givenName: "Ines Teles Correia",
        email: "ines@gmail.com",
        id: "1001",
        picture: "https://avatars.githubusercontent.com/u/4185328?v=4",
        auth_provider: "github",
        app_id: 1,
        role: 2
      },
      %{
        givenName: "Nelson Correia",
        email: "nelson@gmail.com",
        id: "1002",
        picture: "https://avatars.githubusercontent.com/u/194400?v=4",
        auth_provider: "github",
        app_id: 1
      },
      %{
        givenName: "Simon Labondance",
        email: "simon@gmail.com",
        id: "1003",
        picture: "https://avatars.githubusercontent.com/u/6057298?v=4",
        auth_provider: "github",
        app_id: 1
      },
      %{
        givenName: "Stephany Rios",
        email: "stephany@gmail.com",
        id: "1004",
        picture: "https://avatars.githubusercontent.com/u/91985721?v=4",
        auth_provider: "github",
        app_id: 1
      },
      %{
        givenName: "Luis Arteiro",
        email: "luis@gmail.com",
        id: "1005",
        picture: "https://avatars.githubusercontent.com/u/17494745?v=4",
        auth_provider: "github",
        app_id: 1
      },
      %{
        givenName: "Oli Evans",
        email: "oli@gmail.com",
        id: "1006",
        picture: "https://avatars.githubusercontent.com/u/58871?v=4",
        auth_provider: "github",
        app_id: 1
      },
      %{
        givenName: "Alan Shaw",
        email: "alan@gmail.com",
        id: "1007",
        picture: "https://avatars.githubusercontent.com/u/152863?v=4",
        auth_provider: "github",
        app_id: 1
      },
      %{
        givenName: "Alex Potsides",
        email: "alex@gmail.com",
        id: "1008",
        picture: "https://avatars.githubusercontent.com/u/665810?v=4",
        auth_provider: "github",
        app_id: 1
      },
      %{
        givenName: "Amanda Huginkiss",
        email: "amanda@gmail.com",
        id: "1009",
        picture: "https://avatars.githubusercontent.com/u/5108244?v=4",
        auth_provider: "email",
        app_id: 1,
        status: 1
      },
      %{
        givenName: "Andrew McAwesome",
        email: "andrew@gmail.com",
        id: "1010",
        picture: "https://avatars.githubusercontent.com/u/46572910?v=4",
        auth_provider: "email",
        app_id: 1,
        status: 1
      },
      %{
        givenName: "Emmet Brickowski",
        email: "emmet@gmail.com",
        id: "1011",
        picture: "https://avatars.githubusercontent.com/u/10835816?v=4",
        auth_provider: "google",
        app_id: 1,
        status: 1
      },
      %{
        givenName: "Amélie McAwesome",
        email: "ami@gmail.com",
        id: "1012",
        picture: "https://avatars.githubusercontent.com/u/22345430?v=4",
        auth_provider: "google",
        app_id: 1,
        status: 1
      }
    ]
  end

  def insert_sample_people do
    Enum.each(sample_people(), fn person ->
      Auth.Person.upsert_person(person)
    end)
  end
end
