defmodule Realworld.Support.User do
  use Ash.Resource,
      data_layer: AshPostgres.DataLayer

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
end
