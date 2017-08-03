defmodule Conduit.Accounts.Notifications do
  alias Conduit.Accounts.User
  alias Conduit.Repo

  @doc """
  Wait until the given read model is updated to the given version
  """
  def wait_for(schema, uuid, version) do
    case Repo.get_by(schema, uuid: uuid, version: version) do
      nil -> subscribe_and_wait(schema, uuid, version)
      projection -> {:ok, projection}
    end
  end

  @doc """
  Publish updated user read model to interested subscribers
  """
  def publish_changes(%{user: %User{} = user}), do: publish(user)
  def publish_changes(%{user: {_, users}}) when is_list(users), do: Enum.each(users, &publish/1)
  def publish_changes(_changes), do: :ok

  defp publish(%User{uuid: uuid, version: version} = user) do
    Registry.dispatch(Conduit.Accounts, {User, uuid, version}, fn entries ->
      for {pid, _} <- entries, do: send(pid, {User, user})
    end)
  end

  # Subscribe to notifications of read model updates and wait for the expected version
  defp subscribe_and_wait(schema, uuid, version) do
    Registry.register(Conduit.Accounts, {schema, uuid, version}, [])

    receive do
      {^schema, projection} -> {:ok, projection}
    after
      5_000 -> {:error, :timeout}
    end
  end
end
