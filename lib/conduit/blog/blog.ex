defmodule Conduit.Blog do
  @moduledoc """
  The boundary for the Blog system.
  """

  alias Conduit.Accounts.User
  alias Conduit.Blog.{Article,Author,Comment,FavoritedArticle}
  alias Conduit.Blog.Commands.{FavoriteArticle,CommentOnArticle,CreateAuthor,DeleteComment,FavoriteArticle,PublishArticle,UnfavoriteArticle}
  alias Conduit.Blog.Queries.{ArticleBySlug,ArticleComments,ListArticles,ListTags}
  alias Conduit.{Repo,Router,Wait}

  @doc """
  Get the author for a given user account, or return `nil` if not found
  """
  def get_author(nil), do: nil
  def get_author(%User{uuid: user_uuid}), do: Repo.get_by(Author, user_uuid: user_uuid)

  @doc """
  Get the author for a given user account, or raise an `Ecto.NoResultsError` if not found
  """
  def get_author!(%User{uuid: user_uuid}) do
    Repo.get_by!(Author, user_uuid: user_uuid)
  end

  @doc """
  Get an author by their username, or raise an `Ecto.NoResultsError` if not found
  """
  def author_by_username!(username), do: Repo.get_by!(Author, username: username)

  @doc """
  Returns most recent articles globally by default.

  Provide tag, author, or favorited query parameter to filter results.
  """
  @spec list_articles(params :: map(), author :: Author.t) :: {articles :: list(Article.t), article_count :: non_neg_integer()}
  def list_articles(params \\ %{}, author \\ nil)
  def list_articles(params, author) do
    ListArticles.paginate(params, author, Repo)
  end

  @doc """
  Get an article by its URL slug, or return `nil` if not found
  """
  def article_by_slug(slug), do: article_by_slug_query(slug) |> Repo.one()

  @doc """
  Get an article by its URL slug, or raise an `Ecto.NoResultsError` if not found
  """
  def article_by_slug!(slug), do: article_by_slug_query(slug) |> Repo.one!()

  @doc """
  Get comments from an article
  """
  def article_comments(%Article{uuid: article_uuid}) do
    article_uuid
    |> ArticleComments.new()
    |> Repo.all()
  end

  @doc """
  Get a comment by its UUID, or raise an `Ecto.NoResultsError` if not found
  """
  def get_comment!(comment_uuid), do: Repo.get!(Comment, comment_uuid)

  @doc """
  List all tags
  """
  def list_tags do
    ListTags.new() |> Repo.all() |> Enum.map(&(&1.name))
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
    with :ok <- Router.dispatch(FavoriteArticle.new(article_uuid: article_uuid, favorited_by_author_uuid: author_uuid)),
         :ok <- Wait.until(fn -> favorited_article(article_uuid, author_uuid) != nil end),
         article <- Repo.get(Article, article_uuid) do
      {:ok, %Article{article | favorited: true}}
    else
      reply -> reply
    end
  end

  @doc """
  Unfavorite the article for an author
  """
  def unfavorite_article(%Article{uuid: article_uuid}, %Author{uuid: author_uuid}) do
    with :ok <- Router.dispatch(UnfavoriteArticle.new(article_uuid: article_uuid, unfavorited_by_author_uuid: author_uuid)),
         :ok <- Wait.until(fn -> favorited_article(article_uuid, author_uuid) == nil end),
         article <- Repo.get(Article, article_uuid) do
      {:ok, %Article{article | favorited: false}}
    else
      reply -> reply
    end
  end

  @doc """
  Add a comment to an article
  """
  def comment_on_article(%Article{} = article, %Author{} = author, attrs \\ %{}) do
    uuid = UUID.uuid4()

    attrs
    |> CommentOnArticle.new()
    |> CommentOnArticle.assign_uuid(uuid)
    |> CommentOnArticle.assign_article(article)
    |> CommentOnArticle.assign_author(author)
    |> Router.dispatch()
    |> case do
      :ok -> Wait.until(fn -> Repo.get(Comment, uuid) end)
      reply -> reply
    end
  end

  @doc """
  Delete a comment made by the user. Returns `:ok` on success
  """
  def delete_comment(%Comment{} = comment, %Author{} = author) do
    %DeleteComment{}
    |> DeleteComment.assign_comment(comment)
    |> DeleteComment.deleted_by(author)
    |> Router.dispatch()
  end

  defp article_by_slug_query(slug) do
    slug
    |> String.downcase()
    |> ArticleBySlug.new()
  end

  defp favorited_article(article_uuid, favorited_by_author_uuid) do
    Repo.get_by(FavoritedArticle, article_uuid: article_uuid, favorited_by_author_uuid: favorited_by_author_uuid)
  end
end
