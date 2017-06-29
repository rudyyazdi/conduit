defmodule Conduit.Blog.Workflows.CreateAuthorFromUser do
  use Commanded.Event.Handler, name: "Blog.Workflows.CreateAuthorFromUser"

  alias Conduit.Accounts.Events.UserRegistered
  alias Conduit.Blog

  def handle(%UserRegistered{uuid: user_uuid, username: username}, _metadata) do
    {:ok, _author} = Blog.create_author(%{user_uuid: user_uuid, username: username})

    :ok
  end
end
