defmodule OptionsTrackerWeb.PositionLive.Helpers do
  alias OptionsTracker.Accounts
  alias OptionsTracker.Accounts.Position

  @spec type_display(Position.t()) :: String.t()
  def type_display(%Position{type: :stock, basis: basis}),
    do: " (#{currency_string(basis)} basis)"

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
    |> Enum.find(fn {t, _value} -> t == type end)
    |> elem(1)
  end

  @spec position_status_map(atom | boolean) :: Keyword.t() | non_neg_integer()
  def position_status_map(past_tense \\ false)

  def position_status_map(past_tense) when is_boolean(past_tense) do
    Accounts.list_position_statuses()
    |> Enum.map(fn {status, value} ->
      {Accounts.name_for_position_status(status, past_tense), value}
    end)
  end

  def position_status_map(nil), do: nil

  def position_status_map(status) when is_atom(status) do
    Accounts.list_position_statuses()
    |> Enum.find(fn {s, _value} -> s == status end)
    |> elem(1)
  end

  @spec position_status_display(atom, boolean) :: String.t()
  def position_status_display(status, past_tense) do
    Accounts.list_position_statuses()
    |> Enum.find(fn {s, _value} -> s == status end)
    |> elem(0)
    |> Accounts.name_for_position_status(past_tense)
  end

  @spec credit_debit_display(number) :: String.t()
  def credit_debit_display(value) do
    value_string =
      value
      |> abs()
      |> currency_string()

    "#{value_string}#{if(value >= 0, do: "cr", else: "db")}"
  end

  def row_class_for_status(:closed), do: "has-background-grey-lighter"
  def row_class_for_status(:open), do: ""
  def row_class_for_status(:rolled), do: "has-background-warning-light"
  def row_class_for_status(:exercised), do: "has-background-grey-lighter"

  @spec currency_string(float) :: String.t()
  def currency_string(float) do
    float
    |> Decimal.from_float()
    |> Decimal.round(2, :half_up)
    |> Decimal.to_string()
    |> String.replace_prefix("", "$")
  end
end
