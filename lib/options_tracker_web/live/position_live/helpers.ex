defmodule OptionsTrackerWeb.PositionLive.Helpers do
  alias OptionsTracker.Accounts
  alias OptionsTracker.Accounts.Account
  alias OptionsTracker.Accounts.Position

  @spec type_display(Position.t()) :: String.t()
  def type_display(%Position{type: :stock, basis: basis}),
    do: " (#{OptionsTrackerWeb.LiveHelpers.currency_string(basis)} basis)"

  def type_display(%Position{type: :call}), do: "c"
  def type_display(%Position{type: :put}), do: "p"

  def count_type(%Position{type: :stock, count: 1}), do: "share"
  def count_type(%Position{type: :stock, count: c}) when c > 1, do: "shares"
  def count_type(_position), do: "lot"

  @spec position_type_map :: Keyword.t()
  def position_type_map() do
    Accounts.list_position_types()
    |> Enum.map(fn {type, value} -> {Accounts.name_for_position_type(type), value} end)
  end

  @spec position_type_map(atom) :: non_neg_integer
  def position_type_map(nil), do: nil

  def position_type_map(type) do
    Accounts.list_position_types()
    |> Enum.find(fn {t, value} -> t == type || value == type end)
    |> elem(1)
  end

  @spec position_status_map(atom | non_neg_integer, atom | boolean) :: Keyword.t() | non_neg_integer()
  def position_status_map(type, past_tense \\ false)

  def position_status_map(type, past_tense) when is_boolean(past_tense) do
    Accounts.list_position_statuses(type)
    |> Enum.reject(fn {s, _value} -> s in [:rolled] end)
    |> Enum.map(fn {status, _value} ->
      {Accounts.name_for_position_status(status, past_tense), status}
    end)
  end

  def position_status_map(_type, nil), do: nil

  def position_status_map(type, status) when is_atom(status) do
    Accounts.list_position_statuses(type)
    |> Enum.find(fn {s, value} -> s == status || value == status end)
    |> elem(1)
  end

  @spec position_status_display(atom, atom | non_neg_integer, boolean) :: String.t()
  def position_status_display(type, nil, past_tense) do
    position_status_display(type, Accounts.position_status_open(), past_tense)
  end
  def position_status_display(type, status, past_tense) do
    Accounts.list_position_statuses(type)
    |> Enum.find(fn {s, value} -> s == status || value == status end)
    |> elem(0)
    |> Accounts.name_for_position_status(past_tense)
  end

  @spec accounts_select([Account.t()], String.t()) :: Keyword.t()
  def accounts_select(accounts, placeholder) do
    account_options =
      accounts
      |> Enum.map(fn %Account{id: id, name: name, broker_name: broker_name, type: type} ->
        {"#{name} (#{Accounts.name_for_type(type) || broker_name})", id}
      end)

    [placeholder | account_options]
  end

  @spec credit_debit_display(number) :: String.t()
  def credit_debit_display(value) do
    value_string =
      value
      |> abs()
      |> OptionsTrackerWeb.LiveHelpers.currency_string()

    "#{value_string}#{if(value >= 0, do: "cr", else: "db")}"
  end

  @spec is_option?(%{
          data: OptionsTracker.Accounts.Position.t() | map,
          params: nil | maybe_improper_list | map
        } | OptionsTracker.Accounts.Position.t()) :: boolean
  def is_option?(%Phoenix.HTML.Form{params: params, data: %Position{} = position}) do
    type = params["type"] || position.type
    if is_atom(type) do
      type != OptionsTracker.Accounts.Position.TransType.stock_key()
    else
      type != OptionsTracker.Accounts.Position.TransType.stock()
    end
  end
  def is_option?(%Phoenix.HTML.Form{data: %{}}) do
    true
  end
  def is_option?(%Position{type: type}) do
    type != OptionsTracker.Accounts.Position.TransType.stock_key()
  end

  @spec is_short?(%{
          data: OptionsTracker.Accounts.Position.t() | map,
          params: nil | maybe_improper_list | map
        }) :: any
  def is_short?(%{params: params, data: %Position{} = position}) do
    short = params["short"] || position.short

    if is_binary(short) do
      short != "" && short != "false"
    else
      short
    end
  end
  def is_short?(%{data: %{}}) do
    true
  end

  @spec is_closed?(OptionsTracker.Accounts.Position.t()) :: boolean
  def is_closed?(%Position{status: status}) do
    status != Accounts.position_status_open() && status != Accounts.position_status_open_key()
  end

  @spec is_open?(OptionsTracker.Accounts.Position.t()) :: boolean
  def is_open?(%Position{status: status}) do
    status == Accounts.position_status_open() || status == Accounts.position_status_open_key()
  end

  @spec row_class_for_status(:closed | :exercised | :open | :rolled) :: binary
  def row_class_for_status(:closed), do: "has-background-grey-lighter"
  def row_class_for_status(:open), do: ""
  def row_class_for_status(:rolled), do: "has-background-warning-light"
  def row_class_for_status(:exercised), do: "has-background-grey-lighter"

  @spec date_display(Date.t(), boolean) :: String.t()
  def date_display(%Date{year: year, month: month, day: day}, show_year) do
    if show_year do
      "#{month}/#{day}/#{year}"
    else
      "#{month}/#{day}"
    end
  end
  def date_display(nil, _), do: ""
end
