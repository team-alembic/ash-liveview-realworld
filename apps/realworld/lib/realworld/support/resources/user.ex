defmodule Realworld.Support.User do
  use Ash.Resource

  actions do
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    uuid_primary_key :id

    attribute :email, :string
  end
end
