defmodule Conduit.Accounts.User do
  use Ecto.Schema

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "accounts_users" do
    field :user_version, :integer, default: 0
    field :username, :string, unique: true
    field :email, :string, unique: true
    field :hashed_password, :string

    timestamps()
  end
end
