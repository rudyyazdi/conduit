defmodule Conduit.Router do
  use Commanded.Commands.Router

  alias Conduit.Accounts.Aggregates.User
  alias Conduit.Accounts.Commands.RegisterUser

  alias Conduit.Blog.Aggregates.{Article,Author}
  alias Conduit.Blog.Commands.{CreateAuthor,PublishArticle}

  middleware Conduit.Validation.Middleware.Validate
  middleware Conduit.Validation.Middleware.Uniqueness

  dispatch [PublishArticle], to: Article, identity: :uuid

  dispatch [CreateAuthor], to: Author, identity: :uuid

  dispatch [RegisterUser], to: User, identity: :uuid
end
