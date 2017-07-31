defmodule Conduit.Blog.Workflows.CreateAuthorFromUser do
  use Commanded.Event.Handler, name: "Blog.Workflows.CreateAuthorFromUser"

  alias Conduit.Accounts.Events.UserRegistered
  alias Conduit.Blog.Commands.CreateAuthor
  alias Conduit.Router

  def handle(%UserRegistered{uuid: user_uuid, username: username}, _metadata) do
    :ok = Router.dispatch(%CreateAuthor{
      uuid: UUID.uuid4(),
      user_uuid: user_uuid,
      username: username,
    })
  end
end
