defmodule OptionsTrackerWeb.PositionLive.Helpers do
  alias OptionsTracker.Accounts
  alias OptionsTracker.Accounts.Position
  alias OptionsTrackerWeb.Router.Helpers, as: Routes

  @spec type_display(Position.t()) :: String.t()
  def type_display(%Position{type: :stock, basis: basis}),
    do: "#{OptionsTrackerWeb.LiveHelpers.currency_string(basis)} basis"

  def type_display(%Position{type: :call}), do: "Call"
  def type_display(%Position{type: :put}), do: "Put"
  def type_display(%Position{type: :call_spread}), do: "Call Spread"
  def type_display(%Position{type: :put_spread}), do: "Put Spread"

  def type_display_class(%Position{type: :stock}), do: "is-info"
  def type_display_class(%Position{type: :call}), do: "is-success"
  def type_display_class(%Position{type: :call_spread}), do: "is-success is-light"
  def type_display_class(%Position{type: :put}), do: "is-danger"
  def type_display_class(%Position{type: :put_spread}), do: "is-danger is-light"

  def count_type(%Position{type: :stock, count: 1}), do: "share"
  def count_type(%Position{type: :stock, count: c}) when c > 1, do: "shares"
  def count_type(_position), do: "lot"

  @spec position_type_map :: Keyword.t()
  def position_type_map() do
    Accounts.list_position_types()
    |> Keyword.keys()
    # [:call, :call_spread, :put, :put_spread, :stock] This order makes hitting `c` or `p` takes you to call and put first and then the spread
    |> Enum.sort(:asc)
    |> Enum.map(fn type -> {Accounts.name_for_position_type(type), type} end)
  end

  @spec position_type_map(atom) :: non_neg_integer
  def position_type_map(nil), do: nil

  def position_type_map(type) do
    Accounts.list_position_types()
    |> Enum.find(fn {t, value} -> t == type || value == type end)
    |> elem(1)
  end

  @spec position_status_map(atom | non_neg_integer, atom | boolean) ::
          Keyword.t() | non_neg_integer()
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

  @spec max_profit(OptionsTracker.Accounts.Position.t()) :: Decimal.t()
  def max_profit(%Position{} = position) do
    Accounts.calculate_max_profit(position)
  end

  @spec credit_debit_display(Decimal.t()) :: String.t()
  def credit_debit_display(%Decimal{} = value) do
    value_string =
      value
      |> Decimal.abs()
      |> OptionsTrackerWeb.LiveHelpers.currency_string()

    credit_debit_str = if(Decimal.cmp(value, Decimal.new(0)) in [:eq, :gt], do: "cr", else: "db")

    "#{value_string}#{credit_debit_str}"
  end

  @spec is_option?(
          %{
            data: OptionsTracker.Accounts.Position.t() | map,
            params: nil | maybe_improper_list | map
          }
          | OptionsTracker.Accounts.Position.t()
        ) :: boolean
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

  @spec is_naked?(OptionsTracker.Accounts.Position.t()) :: boolean
  def is_naked?(%Position{type: type}) when type in [:call, :put], do: true
  def is_naked?(_position), do: false

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

  def calculate_roi(%Decimal{} = max_profit, %Decimal{} = max_loss) do
    if Decimal.cmp(max_loss, 0) == :eq do
      Decimal.from_float(0.0)
    else
      Decimal.div(max_profit, max_loss)
    end
  end

  @spec is_closed?(OptionsTracker.Accounts.Position.t()) :: boolean
  def is_closed?(%Position{status: status}) do
    status != Accounts.position_status_open() && status != Accounts.position_status_open_key()
  end

  @spec is_open?(OptionsTracker.Accounts.Position.t()) :: boolean
  def is_open?(%Position{status: status}) do
    status == Accounts.position_status_open() || status == Accounts.position_status_open_key()
  end

  @spec is_spread?(
          %{
            data: OptionsTracker.Accounts.Position.t() | map,
            params: nil | maybe_improper_list | map
          }
          | OptionsTracker.Accounts.Position.t()
        ) :: boolean
  def is_spread?(%Phoenix.HTML.Form{params: params, data: %Position{} = position}) do
    type = params["type"] || position.type

    OptionsTracker.Accounts.Position.TransType.call_spread?(type) ||
      OptionsTracker.Accounts.Position.TransType.put_spread?(type)
  end

  def is_spread?(%Phoenix.HTML.Form{data: %{}}) do
    false
  end

  def is_spread?(%Position{type: type}) do
    OptionsTracker.Accounts.Position.TransType.call_spread?(type) ||
      OptionsTracker.Accounts.Position.TransType.put_spread?(type)
  end

  def return_to_path(socket, :all) do
    Routes.position_index_path(socket, :index)
  end

  def return_to_path(socket, current_account_id) do
    Routes.position_account_index_path(socket, :index, current_account_id)
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
