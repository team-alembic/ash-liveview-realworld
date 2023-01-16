defmodule Realworld.Support.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource]

  postgres do
    table "users"
    repo Realworld.Repo
  end

  actions do
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    uuid_primary_key :id

    attribute :email, :string
  end

  json_api do
    type "user"

    routes do
      base("/users")

      index(:read)
    end
  end
end
