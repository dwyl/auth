defmodule Auth.InitPeople do

  def sample_people do
    [
      %{
        givenName: "Ines Teles Correia",
        email: "ines@gmail.com",
        username: "iteles",
        id: "1001",
        picture: "https://avatars.githubusercontent.com/u/4185328?v=4",
        auth_provider: "github",
        app_id: 1,
        role: 2,
        username: "iteles"
      },
      %{
        givenName: "Nelson Correia",
        email: "nelson@gmail.com",
        username: "nelsonic",
        id: "1002",
        picture: "https://avatars.githubusercontent.com/u/194400?v=4",
        auth_provider: "github",
        app_id: 1,
        username: "nelsonic"
      },
      %{
        givenName: "Simon Labondance",
        email: "simon@gmail.com",
        username: "SimonLab",
        id: "1003",
        picture: "https://avatars.githubusercontent.com/u/6057298?v=4",
        auth_provider: "github",
        app_id: 1,
        username: "SimonLab"
      },
      %{
        givenName: "Stephany Rios",
        email: "stephany@gmail.com",
        username: "Stephany",
        id: "1004",
        picture: "https://avatars.githubusercontent.com/u/91985721?v=4",
        auth_provider: "github",
        app_id: 1,
        username: "Stephany"
      },
      %{
        givenName: "Luis Arteiro",
        email: "luis@gmail.com",
        username: "LuchoTurtle",
        id: "1005",
        picture: "https://avatars.githubusercontent.com/u/17494745?v=4",
        auth_provider: "github",
        app_id: 1,
        username: "LuchoTurtle"
      },
      %{
        givenName: "Oli Evans",
        email: "oli@gmail.com",
        username: "olizilla",
        id: "1006",
        picture: "https://avatars.githubusercontent.com/u/58871?v=4",
        auth_provider: "github",
        app_id: 1,
        username: "Olizilla"
      },
      %{
        givenName: "Alan Shaw",
        email: "alan@gmail.com",
        username: "alanshaw",
        id: "1007",
        picture: "https://avatars.githubusercontent.com/u/152863?v=4",
        auth_provider: "github",
        app_id: 1,
        username: "alanshaw"
      },
      %{
        givenName: "Alex Potsides",
        email: "alex@gmail.com",
        username: "achingbrain",
        id: "1008",
        picture: "https://avatars.githubusercontent.com/u/665810?v=4",
        auth_provider: "github",
        app_id: 1,
        username: "achingbrain"
      },
      %{
        givenName: "Amanda Huginkiss",
        email: "amanda@gmail.com",
        username: "amandahuginkiss",
        id: "1009",
        picture: "https://avatars.githubusercontent.com/u/5108244?v=4",
        auth_provider: "email",
        app_id: 1,
        status: 1,
        username: "amandahuginkiss"
      },
      %{
        givenName: "Andrew McAwesome",
        email: "andrew@gmail.com",
        username: "everythingisawesome",
        id: "1010",
        picture: "https://avatars.githubusercontent.com/u/46572910?v=4",
        auth_provider: "email",
        app_id: 1,
        status: 1,
        username: "andy"
      },
      %{
        givenName: "Emmet Brickowski",
        email: "emmet@gmail.com",
        username: "masterbuilder",
        id: "1011",
        picture: "https://avatars.githubusercontent.com/u/10835816?v=4",
        auth_provider: "google",
        app_id: 1,
        status: 1,
        username: "nkamc"
      },
      %{
        givenName: "Amélie McAwesome",
        email: "ami@gmail.com",
        username: "ameliepoulin",
        id: "1012",
        picture: "https://avatars.githubusercontent.com/u/22345430?v=4",
        auth_provider: "google",
        app_id: 1,
        status: 1,
        username: "amelie"
      }
    ]
  end

  def insert_sample_people do
    Enum.each(sample_people(), fn person ->
      Auth.Person.upsert_person(person)
    end)
  end
end
