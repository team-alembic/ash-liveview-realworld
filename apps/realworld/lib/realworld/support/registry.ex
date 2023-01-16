defmodule Realworld.Support.Registry do
  use Ash.Registry,
    extensions: [
      Ash.Registry.ResourceValidations
    ]

  entries do
    entry Realworld.Support.User
  end
end
