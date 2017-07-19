defmodule Conduit.Blog.Tag do
  use Ecto.Schema

  @primary_key {:uuid, :binary_id, autogenerate: true}

  schema "blog_tags" do
    field :name, :string

    timestamps()
  end
end
