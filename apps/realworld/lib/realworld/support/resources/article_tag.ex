defmodule Realworld.Support.ArticleTag do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "article_tags"
    repo Realworld.Repo
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :article, Realworld.Support.Article do
      allow_nil? false
    end

    belongs_to :tag, Realworld.Support.Tag do
      allow_nil? false
    end
  end
end
