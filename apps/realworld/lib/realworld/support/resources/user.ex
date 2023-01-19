defmodule Realworld.Support.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "users"
    repo Realworld.Repo
  end

  actions do
    create :registration do
      accept [:username, :email, :password]
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :username, :string
    attribute :email, :string
    attribute :password, :string
    attribute :bio, :string
    attribute :image, :string
    attribute :token, :string
  end

  identities do
    identity :unique_email, [:email]
    identity :unique_username, [:username]
  end

  validations do
    validate present(:email), on: :create
    validate present(:password), on: :create
    validate present(:password), on: :create
  end
end
