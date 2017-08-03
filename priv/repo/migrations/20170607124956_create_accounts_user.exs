defmodule Conduit.Repo.Migrations.CreateConduit.Accounts.User do
  use Ecto.Migration

  def change do
    create table(:accounts_users, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :version, :integer, default: 0
      add :username, :string
      add :email, :string
      add :hashed_password, :string

      timestamps()
    end

    create unique_index(:accounts_users, [:uuid, :version])
    create unique_index(:accounts_users, [:username])
    create unique_index(:accounts_users, [:email])
  end
end
