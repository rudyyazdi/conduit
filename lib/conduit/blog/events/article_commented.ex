defmodule Conduit.Blog.Events.ArticleCommented do
  @derive [Poison.Encoder]
  defstruct [
    :uuid,
    :body,
    :article_uuid,
    :author_uuid,
  ]
end
