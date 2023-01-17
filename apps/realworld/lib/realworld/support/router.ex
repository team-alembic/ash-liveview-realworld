defmodule Realworld.Support.Router do
  use AshJsonApi.Api.Router,
    api: Realworld.Support,
    registry: Realworld.Support.Registry
end
