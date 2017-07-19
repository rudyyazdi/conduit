defmodule ConduitWeb.ConnHelpers do
  import Plug.Conn
  import Conduit.Fixture

  alias Conduit.Blog.Author
  alias Conduit.{Repo,Wait}

  def authenticated_conn(conn) do
    with {:ok, user} <- fixture(:user),
         {:ok, _author} <- get_author(user)
    do
      authenticated_conn(conn, user)
    end
  end

  def authenticated_conn(conn, user) do
    {:ok, jwt} = ConduitWeb.JWT.generate_jwt(user)

    conn
    |> put_req_header("authorization", "Token " <> jwt)
  end

  defp get_author(user) do
    Wait.until(fn -> Repo.get_by(Author, user_uuid: user.uuid) end)
  end
end
