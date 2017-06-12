defmodule Conduit.Accounts do
  @moduledoc """
  The boundary for the Accounts system.
  """

  alias Conduit.Accounts.Commands.RegisterUser
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

  # generate a unique identity
  defp assign_uuid(attrs, uuid), do: Map.put(attrs, :uuid, uuid)
end
