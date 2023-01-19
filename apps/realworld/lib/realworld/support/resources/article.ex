defmodule Realworld.Support.Article do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

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

  relationships do
    belongs_to :user, Realworld.Support.User

    many_to_many :tag_list, Realworld.Support.Tag do
      through Realworld.Support.ArticleTag
      source_attribute_on_join_resource :article_id
      destination_attribute_on_join_resource :tag_id
    end
  end
end
