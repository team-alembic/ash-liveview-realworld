defmodule Realworld.Support do
  use Ash.Api

  resources do
    registry Realworld.Support.Registry
  end
end
