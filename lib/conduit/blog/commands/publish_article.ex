defmodule Conduit.Blog.Commands.PublishArticle do
  defstruct [
    uuid: "",
    slug: "",
    title: "",
    description: "",
    body: "",
    tag_list: [],
    author_uuid: "",
  ]

  use ExConstructor
  use Vex.Struct

  alias Conduit.Blog.{Author,Slugger}
  alias Conduit.Blog.Commands.PublishArticle

  validates :uuid, uuid: true

  validates :slug,
    presence: [message: "can't be empty"],
    format: [with: ~r/^[a-z0-9\-]+$/, allow_nil: true, allow_blank: true, message: "is invalid"],
    string: true,
    unique_article_slug: true

  validates :title, presence: [message: "can't be empty"], string: true

  validates :description, presence: [message: "can't be empty"], string: true

  validates :body, presence: [message: "can't be empty"], string: true

  validates :tag_list, by: &is_list/1

  validates :author_uuid, uuid: true

  @doc """
  Assign a unique identity
  """
  def assign_uuid(%PublishArticle{} = publish_article, uuid) do
    %PublishArticle{publish_article | uuid: uuid}
  end

  @doc """
  Assign the author
  """
  def assign_author(%PublishArticle{} = publish_article, %Author{uuid: uuid}) do
    %PublishArticle{publish_article | author_uuid: uuid}
  end

  @doc """
  Generate a unique URL slug from the article title
  """
  def generate_url_slug(%PublishArticle{title: title} = publish_article) do
    case Slugger.slugify(title) do
      {:ok, slug} -> %PublishArticle{publish_article | slug: slug}
      _ -> publish_article
    end
  end
end

defimpl Conduit.Validation.Middleware.Uniqueness.UniqueFields, for: Conduit.Blog.Commands.PublishArticle do
  def unique(%Conduit.Blog.Commands.PublishArticle{uuid: uuid}), do: [
    {:slug, "has already been taken", uuid},
  ]
end
