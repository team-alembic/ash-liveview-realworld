defmodule Realworld.Support.Token do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication.TokenResource]

  postgres do
    table "tokens"
    repo Realworld.Repo
  end

  token do
    api Realworld.Support
  end
end
