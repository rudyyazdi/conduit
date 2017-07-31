defmodule Conduit.Blog.Events.AuthorCreated do
  @derive [Poison.Encoder]
  defstruct [
    :uuid,
    :user_uuid,
    :username,
  ]
end
