defmodule OptionsTrackerWeb.PositionLive.Helpers do
  alias OptionsTracker.Accounts

  def type_display(:stock), do: ""
  def type_display(:call), do: "c"
  def type_display(:put), do: "p"

  def position_type_map() do
    Accounts.list_position_types()
    |> Enum.map(fn {type, value} -> {Accounts.name_for_position_type(type), value} end)
  end
end
