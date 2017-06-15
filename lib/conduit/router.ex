defmodule Conduit.Router do
  use Commanded.Commands.Router

  alias Conduit.Accounts.Aggregates.User
  alias Conduit.Accounts.Commands.RegisterUser

  middleware Conduit.Validation.Middleware.Validate
  middleware Conduit.Validation.Middleware.Uniqueness

  dispatch [RegisterUser], to: User, identity: :uuid
end
