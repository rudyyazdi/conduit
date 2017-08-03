defmodule Conduit.Accounts.Projectors.User do
  use Commanded.Projections.Ecto, name: "Accounts.Projectors.User"

  alias Conduit.Accounts.Events.{
    UserEmailChanged,
    UsernameChanged,
    UserPasswordChanged,
    UserRegistered,
  }
  alias Conduit.Accounts.User

  project %UserRegistered{} = registered, %{stream_version: user_version} do
    Ecto.Multi.insert(multi, :user, %User{
      uuid: registered.uuid,
      user_version: user_version,
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

  defp update_user(multi, user_uuid, metadata, changes) do
    Ecto.Multi.update_all(multi, :user, user_query(user_uuid), set: changes ++ [
      user_version: metadata.stream_version,
    ])
  end

  defp user_query(user_uuid) do
    from(u in User, where: u.uuid == ^user_uuid)
  end
end
