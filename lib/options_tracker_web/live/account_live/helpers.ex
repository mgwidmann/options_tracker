defmodule OptionsTrackerWeb.AccountLive.Helpers do
  alias OptionsTracker.Accounts

  @spec account_type_map :: Keyword.t()
  def account_type_map() do
    Accounts.list_account_types()
    |> Enum.map(fn {type, value} -> {account_type_display(type, "Other"), value} end)
  end

  @spec account_type_display(atom, String.t()) :: nil | String.t()
  def account_type_display(type, broker_name) do
    Accounts.name_for_type(type) || broker_name
  end
end
