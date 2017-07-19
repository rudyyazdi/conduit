defmodule Conduit.AggregateCase do
  @moduledoc """
  This module defines the test case to be used by aggregate tests.
  """

  use ExUnit.CaseTemplate

  using [aggregate: aggregate] do
    quote bind_quoted: [aggregate: aggregate] do
      @aggregate aggregate

      import Conduit.Factory

      # assert that the expected events are returned when the given commands have been executed
      defp assert_events(commands, expected_events) do
        assert_events(%@aggregate{}, commands, expected_events)
      end

      defp assert_events(aggregate, commands, expected_events) do
        {_aggregate, events} = execute(commands, aggregate)

        assert List.wrap(events) == expected_events
      end

      # execute one or more commands against an aggregate
      defp execute(commands, aggregate \\ %@aggregate{})
      defp execute(commands, aggregate) do
        commands
        |> List.wrap()
        |> Enum.reduce({aggregate, []}, fn (command, {aggregate, _}) ->
          events = @aggregate.execute(aggregate, command)

          {evolve(aggregate, events), events}
        end)
      end

      # apply the given events to the aggregate state
      defp evolve(aggregate, events) do
        events
        |> List.wrap()
        |> Enum.reduce(aggregate, &@aggregate.apply(&2, &1))
      end
    end
  end
end
