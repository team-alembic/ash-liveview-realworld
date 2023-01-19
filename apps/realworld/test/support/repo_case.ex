defmodule Realworld.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Realworld.Repo

      import Ecto
      import Ecto.Query
      import Realworld.RepoCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Realworld.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Realworld.Repo, {:shared, self()})
    end

    :ok
  end
end
