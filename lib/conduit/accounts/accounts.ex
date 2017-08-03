defmodule Conduit.Accounts do
  @moduledoc """
  The boundary for the Accounts system.
  """

  alias Conduit.Accounts.Commands.{RegisterUser,UpdateUser}
  alias Conduit.Accounts.Queries.{UserByUsername,UserByEmail}
  alias Conduit.Accounts.User
  alias Conduit.Repo
  alias Conduit.Router
  alias Conduit.Wait

  @doc """
  Register a new user.
  """
  def register_user(attrs \\ %{}) do
    uuid = UUID.uuid4()

    attrs
    |> RegisterUser.new()
    |> RegisterUser.assign_uuid(uuid)
    |> RegisterUser.downcase_username()
    |> RegisterUser.downcase_email()
    |> RegisterUser.hash_password()
    |> Router.dispatch()
    |> case do
      :ok -> Wait.until(fn -> user_by_uuid(uuid) end)
      reply -> reply
    end
  end

  @doc """
  Update the email, username, and/or password of a user.
  """
  def update_user(%User{uuid: user_uuid} = user, attrs \\ %{}) do
    attrs
    |> UpdateUser.new()
    |> UpdateUser.assign_user(user)
    |> UpdateUser.downcase_username()
    |> UpdateUser.downcase_email()
    |> UpdateUser.hash_password()
    |> Router.dispatch(include_aggregate_version: true)
    |> case do
      {:ok, version} -> wait_for_user_version(user_uuid, version)
      reply -> reply
    end
  end

  @doc """
  Get an existing user by their username, or return `nil` if not registered
  """
  def user_by_username(username) when is_binary(username) do
    username
    |> String.downcase()
    |> UserByUsername.new()
    |> Repo.one()
  end

  @doc """
  Get an existing user by their email address, or return `nil` if not registered
  """
  def user_by_email(email) when is_binary(email) do
    email
    |> String.downcase()
    |> UserByEmail.new()
    |> Repo.one()
  end

  @doc """
  Get a single user by their UUID
  """
  def user_by_uuid(uuid) when is_binary(uuid) do
    Repo.get(User, uuid)
  end

  # Wait until the user read model is updated to the given version
  defp wait_for_user_version(user_uuid, version) do
    with :ok <- Wait.until(fn -> user_by_uuid(user_uuid).user_version == version end),
         user <- user_by_uuid(user_uuid) do
      {:ok, user}
    else
      reply -> reply
    end
  end
end
