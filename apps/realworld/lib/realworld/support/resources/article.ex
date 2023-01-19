defmodule Realworld.Support.Article do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource]

  postgres do
    table "articles"
    repo Realworld.Repo
  end

  actions do
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    uuid_primary_key :id
    create_timestamp :created_at
    update_timestamp :updated_at

    attribute :slug, :string do
      allow_nil? false
    end

    attribute :title, :string do
      allow_nil? false
    end

    attribute :description, :string do
      allow_nil? false
    end

    attribute :body, :string do
      allow_nil? false
    end
  end

  json_api do
    type "article"

    routes do
      base("/articles")

      index(:read)
    end
  end
end
