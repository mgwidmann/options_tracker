defmodule OptionsTrackerWeb.TransactionLive.Helpers do
  alias OptionsTracker.Accounts

  def type_display(:stock), do: ""
  def type_display(:call), do: "c"
  def type_display(:put), do: "p"

  def transaction_type_map() do
    Accounts.list_transaction_types()
    |> Enum.map(fn {type, value} -> {Accounts.name_for_transaction_type(type), value} end)
  end
end
