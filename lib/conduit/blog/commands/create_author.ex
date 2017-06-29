defmodule Conduit.Blog.Commands.CreateAuthor do
  defstruct [
    uuid: "",
    user_uuid: "",
    username: "",
  ]

  use ExConstructor
  use Vex.Struct

  alias Conduit.Blog.Commands.CreateAuthor

  validates :uuid, uuid: true

  validates :user_uuid, uuid: true

  validates :username,
    presence: [message: "can't be empty"],
    format: [with: ~r/^[a-z0-9]+$/, allow_nil: true, allow_blank: true, message: "is invalid"],
    string: true

  @doc """
  Assign a unique identity
  """
  def assign_uuid(%CreateAuthor{} = create_author, uuid) do
    %CreateAuthor{create_author |
      uuid: uuid
    }
  end
end
