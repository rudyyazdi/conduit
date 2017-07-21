defmodule Conduit.Router do
  use Commanded.Commands.Router

  alias Conduit.Accounts.Aggregates.User
  alias Conduit.Accounts.Commands.RegisterUser

  alias Conduit.Blog.Aggregates.{Article,Author,Comment}
  alias Conduit.Blog.Commands.{
    CreateAuthor,
    CommentOnArticle,
    FavoriteArticle,
    PublishArticle,
    UnfavoriteArticle,
  }

  middleware Conduit.Validation.Middleware.Validate
  middleware Conduit.Validation.Middleware.Uniqueness

  dispatch [PublishArticle], to: Article, identity: :uuid

  dispatch [
    FavoriteArticle,
    UnfavoriteArticle,
  ], to: Article, identity: :article_uuid

  dispatch [CreateAuthor], to: Author, identity: :uuid

  dispatch [CommentOnArticle], to: Comment, identity: :uuid

  dispatch [RegisterUser], to: User, identity: :uuid
end
