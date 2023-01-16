defmodule Realworld.Support do
  use Ash.Api, extensions: [AshJsonApi.Api]

  resources do
    registry Realworld.Support.Registry
  end
end
