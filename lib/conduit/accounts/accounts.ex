defmodule Conduit.Accounts do
  @moduledoc """
  The boundary for the Accounts system.
  """

  alias Conduit.Accounts.Commands.RegisterUser
  alias Conduit.Accounts.Queries.UserByUsername
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
    |> assign_uuid(uuid)
    |> RegisterUser.new()
    |> Router.dispatch()
    |> case do
      :ok -> Wait.until(fn -> Repo.get(User, uuid) end)
      reply -> reply
    end
  end

  @doc """
  Get an existing user by their username, or return `nil` if not registered
  """
  def user_by_username(username) do
    username
    |> String.downcase()
    |> UserByUsername.new()
    |> Repo.one()
  end

  # generate a unique identity
  defp assign_uuid(attrs, uuid), do: Map.put(attrs, :uuid, uuid)
end
