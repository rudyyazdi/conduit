defmodule Conduit.Blog.Events.ArticlePublished do
  @derive [Poison.Encoder]
  defstruct [
    :uuid,
    :slug,
    :title,
    :description,
    :body,
    :tags,
    :author_uuid,
  ]
end
