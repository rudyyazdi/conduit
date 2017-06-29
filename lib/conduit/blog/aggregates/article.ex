defmodule Conduit.Blog.Aggregates.Article do
  defstruct [
    :uuid,
    :slug,
    :title,
    :description,
    :body,
    :tags,
    :author_uuid,
  ]

  alias Conduit.Blog.Aggregates.Article
  alias Conduit.Blog.Commands.PublishArticle
  alias Conduit.Blog.Events.ArticlePublished

  @doc """
  Publish an article
  """
  def execute(%Article{uuid: nil}, %PublishArticle{} = publish) do
    %ArticlePublished{
      uuid: publish.uuid,
      slug: publish.slug,
      title: publish.title,
      description: publish.description,
      body: publish.body,
      tags: publish.tag_list,
      author_uuid: publish.author_uuid,
    }
  end

  # state mutators

  def apply(%Article{} = article, %ArticlePublished{} = published) do
    %Article{article |
      uuid: published.uuid,
      slug: published.slug,
      title: published.title,
      description: published.description,
      body: published.body,
      tags: published.tags,
      author_uuid: published.author_uuid,
    }
  end
end
