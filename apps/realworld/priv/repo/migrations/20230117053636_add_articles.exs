defmodule Realworld.Repo.Migrations.MigrateResources1 do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:articles, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :created_at, :utc_datetime_usec, null: false, default: fragment("now()")
      add :updated_at, :utc_datetime_usec, null: false, default: fragment("now()")
      add :slug, :text, null: false
      add :title, :text, null: false
      add :description, :text, null: false
      add :body, :text, null: false
    end
  end

  def down do
    drop table(:articles)
  end
end