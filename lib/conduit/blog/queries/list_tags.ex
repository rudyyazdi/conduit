defmodule Conduit.Blog.Queries.ListTags do
  import Ecto.Query

  alias Conduit.Blog.Tag

  def new do
    from t in Tag,
    order_by: t.name
  end
end
