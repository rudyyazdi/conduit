defmodule Conduit.Accounts.Supervisor do
  use Supervisor

  alias Conduit.Accounts

  def start_link do
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    children = [
      supervisor(Registry, [:duplicate, Accounts]),

      # Read model projections
      worker(Accounts.Projectors.User, [], id: :accounts_users_projector),
    ]

    supervise(children, strategy: :one_for_one)
  end
end
