defmodule OptionsTrackerWeb.AccountLive.Helpers do
  alias OptionsTracker.Accounts
  alias OptionsTracker.Accounts.Account

  @spec account_type_map :: Keyword.t()
  def account_type_map() do
    Accounts.list_account_types()
    |> Enum.map(fn {type, _value} -> {account_type_display(type, "Other"), type} end)
  end

  @spec account_type_display(atom, String.t()) :: nil | String.t()
  def account_type_display(type, broker_name) do
    Accounts.name_for_type(type) || broker_name
  end

  @spec accounts_select([Account.t()]) :: Keyword.t()
  def accounts_select(accounts) do
    accounts
    |> Enum.map(fn %Account{id: id, name: name, broker_name: broker_name, type: type} ->
      {"#{name} (#{Accounts.name_for_type(type) || broker_name})", id}
    end)
  end
end
