defmodule Realworld.Support.Registry do
  use Ash.Registry,
    extensions: [
      Ash.Registry.ResourceValidations
    ]

  entries do
    entry Realworld.Support.User
    entry Realworld.Support.Article
    entry Realworld.Support.Tag
    entry Realworld.Support.ArticleTag
    entry Realworld.Support.Comment
    entry Realworld.Support.Token
  end
end
