defmodule Conduit.Accounts.Projectors.User do
  use Commanded.Projections.Ecto, name: "Accounts.Projectors.User"

  alias Conduit.Accounts.Events.{
    UserEmailChanged,
    UsernameChanged,
    UserPasswordChanged,
    UserRegistered,
  }
  alias Conduit.Accounts.User
  alias Conduit.Accounts.Notifications

  project %UserRegistered{} = registered, %{stream_version: version} do
    Ecto.Multi.insert(multi, :user, %User{
      uuid: registered.uuid,
      version: version,
      username: registered.username,
      email: registered.email,
      hashed_password: registered.hashed_password,
    })
  end

  project %UsernameChanged{user_uuid: user_uuid, username: username}, metadata do
    update_user(multi, user_uuid, metadata, username: username)
  end

  project %UserEmailChanged{user_uuid: user_uuid, email: email}, metadata do
    update_user(multi, user_uuid, metadata, email: email)
  end

  project %UserPasswordChanged{user_uuid: user_uuid, hashed_password: hashed_password}, metadata do
    update_user(multi, user_uuid, metadata, hashed_password: hashed_password)
  end

  def after_update(_event, _metadata, changes), do: Notifications.publish_changes(changes)

  defp update_user(multi, user_uuid, metadata, changes) do
    Ecto.Multi.update_all(multi, :user, user_query(user_uuid), [
      set: changes ++ [version: metadata.stream_version]
    ], returning: true)
  end

  defp user_query(user_uuid) do
    from(u in User, where: u.uuid == ^user_uuid)
  end
end
