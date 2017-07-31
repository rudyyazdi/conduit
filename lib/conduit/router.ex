defmodule Conduit.Router do
  use Commanded.Commands.Router

  alias Conduit.Accounts.Aggregates.User
  alias Conduit.Accounts.Commands.RegisterUser
  alias Conduit.Blog.Aggregates.Author
  alias Conduit.Blog.Commands.CreateAuthor

  middleware Conduit.Validation.Middleware.Validate
  middleware Conduit.Validation.Middleware.Uniqueness

  dispatch [RegisterUser], to: User, identity: :uuid

  dispatch [CreateAuthor], to: Author, identity: :uuid
end
