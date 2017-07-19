defmodule Conduit.Blog do
  @moduledoc """
  The boundary for the Blog system.
  """

  alias Conduit.Accounts.User
  alias Conduit.Blog.{Article,Author}
  alias Conduit.Blog.Commands.{CreateAuthor,FavoriteArticle,PublishArticle,UnfavoriteArticle}
  alias Conduit.Blog.Queries.{ArticleBySlug,ListArticles}
  alias Conduit.{Repo,Router,Wait}

  @doc """
  Get the author for a given user account
  """
  def get_author!(%User{uuid: user_uuid}) do
    Repo.get_by!(Author, user_uuid: user_uuid)
  end

  @doc """
  Returns most recent articles globally by default.

  Provide tag, author or favorited query parameter to filter results.
  """
  @spec list_articles(params :: map()) :: {articles :: list(Article.t), article_count :: non_neg_integer()}
  def list_articles(params \\ %{}) do
    ListArticles.paginate(params, Repo)
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
  Favorite the article for an author
  """
  def favorite_article(%Article{uuid: article_uuid}, %Author{uuid: author_uuid}) do
    FavoriteArticle.new(article_uuid: article_uuid, favorited_by_author_uuid: author_uuid)
    |> Router.dispatch()
    |> case do
      :ok -> {:ok, Repo.get(Article, article_uuid)}
      reply -> reply
    end
  end

  @doc """
  Unfavorite the article for an author
  """
  def unfavorite_article(%Article{uuid: article_uuid}, %Author{uuid: author_uuid}) do
    UnfavoriteArticle.new(article_uuid: article_uuid, unfavorited_by_author_uuid: author_uuid)
    |> Router.dispatch()
    |> case do
      :ok -> {:ok, Repo.get(Article, article_uuid)}
      reply -> reply
    end
  end

  @doc """
  Get an article by its URL slug, or return `nil` if not found
  """
  def article_by_slug(slug), do: article_by_slug_query(slug) |> Repo.one()

  @doc """
  Get an article by its URL slug, or raise an `Ecto.NoResultsError` if not found
  """
  def article_by_slug!(slug), do: article_by_slug_query(slug) |> Repo.one!()

  defp article_by_slug_query(slug) do
    slug
    |> String.downcase()
    |> ArticleBySlug.new()
  end
end
