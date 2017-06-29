defmodule Conduit.Blog do
  @moduledoc """
  The boundary for the Blog system.
  """

  alias Conduit.Accounts.User
  alias Conduit.Blog.{Article,Author}
  alias Conduit.Blog.Commands.{CreateAuthor,PublishArticle}
  alias Conduit.Blog.Queries.ArticleBySlug
  alias Conduit.Repo
  alias Conduit.Router
  alias Conduit.Wait

  @doc """
  Get the author for a given user account
  """
  def get_author!(%User{uuid: user_uuid}) do
    Repo.get_by!(Author, user_uuid: user_uuid)
  end

  @doc """
  Create an author
  """
  def create_author(attrs \\ %{}) do
    uuid = UUID.uuid4()

    attrs
    |> CreateAuthor.new()
    |> CreateAuthor.assign_uuid(uuid)
    |> Router.dispatch()
    |> case do
      :ok -> Wait.until(fn -> Repo.get(Author, uuid) end)
      reply -> reply
    end
  end

  @doc """
  Publishes an article by the given author.
  """
  def publish_article(%Author{} = author, attrs \\ %{}) do
    uuid = UUID.uuid4()

    attrs
    |> PublishArticle.new()
    |> PublishArticle.assign_uuid(uuid)
    |> PublishArticle.assign_author(author)
    |> PublishArticle.generate_url_slug()
    |> Router.dispatch()
    |> case do
      :ok -> Wait.until(fn -> Repo.get(Article, uuid) end)
      reply -> reply
    end
  end

  @doc """
  Get an article by its URL slug, or return `nil` if not found
  """
  def article_by_slug(slug) do
    slug
    |> String.downcase()
    |> ArticleBySlug.new()
    |> Repo.one()
  end
end
