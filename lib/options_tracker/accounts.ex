defmodule OptionsTracker.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias OptionsTracker.Repo

  alias OptionsTracker.Accounts.Account

  @system_action_user_id -1

  @spec list_accounts(non_neg_integer | String.t()) :: [Account.t()]
  @doc """
  Returns the list of accounts.

  ## Examples

      iex> list_accounts()
      [%Account{}, ...]

  """
  def list_accounts(user_id) do
    from(a in Account,
      where: a.user_id == ^user_id
    )
    |> order_by(asc: :id)
    |> Repo.all()
  end

  @spec get_account!(non_neg_integer | String.t()) :: Account.t()
  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_account!(id), do: Repo.get!(Account, id)

  @spec create_account(%{optional(binary) => binary | number}) ::
          {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(attrs \\ %{}) do
    %Account{}
    |> Account.create_changeset(attrs)
    |> Repo.insert()
  end

  @spec update_account(OptionsTracker.Accounts.Account.t(), %{optional(binary) => binary | number}) ::
          {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
  @doc """
  Updates a account.

  ## Examples

      iex> update_account(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_account(OptionsTracker.Accounts.Account.t()) ::
          {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
  @doc """
  Deletes a account.

  ## Examples

      iex> delete_account(account)
      {:ok, %Account{}}

      iex> delete_account(account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account changes.

  ## Examples

      iex> change_account(account)
      %Ecto.Changeset{data: %Account{}}

  """
  def change_account(%Account{} = account, attrs \\ %{}) do
    Account.changeset(account, attrs)
  end

  @spec list_account_types :: [
          {:other, 1000} | {:robinhood, 1} | {:tasty_works, 0},
          ...
        ]
  def list_account_types() do
    Account.TypeEnum.__enum_map__()
  end

  @spec name_for_type(atom) :: nil | String.t()
  def name_for_type(type) do
    Account.TypeEnum.name_for(type)
  end

  def defaults_for_type(:tasty_works) do
    %{
      opt_open_fee: Decimal.from_float(1.15),
      opt_close_fee: Decimal.from_float(0.14),
      stock_open_fee: Decimal.from_float(0.00),
      stock_close_fee: Decimal.from_float(0.00),
      exercise_fee: Decimal.from_float(5.00),
      cash: Decimal.from_float(2_000.00)
    }
  end

  def defaults_for_type(:robinhood) do
    %{
      opt_open_fee: Decimal.from_float(0.00),
      opt_close_fee: Decimal.from_float(0.00),
      stock_open_fee: Decimal.from_float(0.00),
      stock_close_fee: Decimal.from_float(0.00),
      exercise_fee: Decimal.from_float(0.00),
      cash: Decimal.from_float(2_000.00)
    }
  end

  def defaults_for_type(_other) do
    # No defaults
    %{}
  end

  defmodule ProfitLoss do
    defstruct daily: 0, weekly: 0, monthly: 0, total: 0
  end

  @doc """

  """
  def profit_loss(%Account{} = account), do: profit_loss([account])

  def profit_loss(accounts) when is_list(accounts) or is_nil(accounts) do
    positions = list_positions(for(a <- accounts || [], do: a.id))

    day_date = Timex.today()
    week_date = Timex.beginning_of_week(day_date, :sun)
    month_date = Timex.beginning_of_month(day_date)

    positions_stream = Stream.filter(positions, & &1.closed_at)

    day_positions = positions_stream |> Stream.filter(&(Timex.compare(&1.closed_at, day_date, :day) == 0))

    week_positions = positions_stream |> Stream.filter(&(Timex.compare(&1.closed_at, week_date, :day) >= 0))

    month_positions = positions_stream |> Stream.filter(&(Timex.compare(&1.closed_at, month_date, :day) >= 0))

    zero = Decimal.from_float(0.0)

    %ProfitLoss{
      daily: day_positions |> Enum.reduce(zero, &Decimal.add(&1.profit_loss, &2)),
      weekly: week_positions |> Enum.reduce(zero, &Decimal.add(&1.profit_loss, &2)),
      monthly: month_positions |> Enum.reduce(zero, &Decimal.add(&1.profit_loss, &2)),
      total: positions_stream |> Enum.reduce(zero, &Decimal.add(&1.profit_loss, &2))
    }
  end

  alias OptionsTracker.Accounts.Position
  alias OptionsTracker.Users.User
  alias OptionsTracker.Audits

  @spec count_positions :: non_neg_integer()
  def count_positions() do
    Repo.aggregate(from(p in Position), :count, :id)
  end

  @doc """
  Returns the list of positions.

  ## Examples

      iex> list_positions(1)
      [%Position{}, ...]

  """
  def list_positions(account_id) when is_number(account_id), do: list_positions([account_id])

  def list_positions(account_ids) when is_list(account_ids) do
    from(p in Position,
      where: p.account_id in ^account_ids
    )
    |> Repo.all()
  end

  @spec search_positions(%{
          account_ids: list(non_neg_integer()),
          search: String.t(),
          open: boolean
        }) :: list(Position.t())
  @doc """
  Search for positions given a set of criteria.
  Parameters:
    * :account_ids - The account IDs to search.
    * :search - The ticker to search.
    * :open - Boolean to indicate to look for open or closed positions.
  """
  def search_positions(params) when is_map(params) do
    account_ids = Map.get(params, :account_ids)
    search = Map.get(params, :search)
    search = if(search, do: "%#{String.upcase(search)}%")
    open = Map.get(params, :open, true)

    query =
      from(p in Position,
        where: p.account_id in ^account_ids
      )

    query =
      if search != "" && search != nil do
        where(query, [p], like(p.stock, ^search))
      else
        query
      end

    open_val = Position.StatusType.open()

    query =
      if open do
        where(query, [p], p.status in ^[open_val])
      else
        where(query, [p], p.status not in ^[open_val])
      end

    query = order_by(query, [p], asc_nulls_first: p.expires_at, asc: p.opened_at)

    Repo.all(query)
  end

  @spec get_position!(number | String.t()) :: Position.t()
  @doc """
  Gets a single position.

  Raises `Ecto.NoResultsError` if the Position does not exist.

  ## Examples

      iex> get_position!(123)
      %Position{}

      iex> get_position!(456)
      ** (Ecto.NoResultsError)

  """
  def get_position!(id), do: Repo.get!(Position, id)

  @spec create_position(
          %{optional(:__struct__) => none, optional(atom | binary) => any},
          User.t()
        ) ::
          {:ok, Position.t()} | {:error, Ecto.Changeset.t()}
  @doc """
  Creates a position.

  ## Examples

      iex> create_position(%{stock: "XYZ"}, %User{id: 123})
      {:ok, %Position{}}

      iex> create_position(%{stock: 45.0}, %User{id: 123})
      {:error, %Ecto.Changeset{}}

  """
  def create_position(attrs, user)

  def create_position(attrs, %User{id: user_id}) do
    Repo.transaction(fn ->
      case %Position{} |> Position.open_changeset(attrs) |> Repo.insert() do
        {:ok, position} ->
          {:ok, _audit} = Audits.position_audit_changeset(:insert, user_id, position) |> Repo.insert()

          position

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  @spec update_position(
          OptionsTracker.Accounts.Position.t(),
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any},
          User.t()
        ) :: Position.t() | {:error, Ecto.Changeset.t()}
  @doc """
  Updates a position.

  ## Examples

      iex> update_position(position, %{notes: "some notes"}, %User{id: 123})
      {:ok, %Position{}}

      iex> update_position(position, %{notes: 1}, %User{id: 123})
      {:error, %Ecto.Changeset{}}

  """
  def update_position(%Position{} = position, attrs, %User{id: user_id}) do
    changeset = position |> Position.changeset(attrs)

    if changeset.valid? do
      Repo.transaction(fn ->
        case Repo.update(changeset) do
          {:ok, position} ->
            update_basis!(position)
            handle_exercise!(position)

            # These changes were made by the user
            Audits.position_audit_changeset(:update, user_id, changeset.data)
            |> Repo.insert!()

            position

          {:error, changeset} ->
            {:error, changeset}
        end
      end)
    else
      {:error, changeset}
    end
  end

  ### Updates any long or short stock positions' basis field which were used as collateral for this position.
  @spec update_basis!(OptionsTracker.Accounts.Position.t()) :: [
          OptionsTracker.Accounts.Position.t()
        ]
  defp update_basis!(%Position{status: :closed, count: count, type: call_or_put, profit_loss: profit_loss} = position)
       when call_or_put in ~w[call put]a do
    # Long stock for call, short stock for put
    short_long = if(call_or_put == :call, do: false, else: true)
    profit_loss_per_contact = Decimal.div(profit_loss, count)

    position
    |> Position.open_related_positions()
    |> Repo.all()
    # Do after retrieval to be able to use index
    |> Enum.reject(fn s ->
      # Can't be used for this option to lower basis
      s.short != short_long || s.count < 100
    end)
    |> pair_contacts_with_stock(count, fn stock, count ->
      basis_delta = Decimal.div(profit_loss_per_contact, stock.count) |> Decimal.mult(count)
      # short stock positions add to basis instead of lowering basis
      basis_delta = if(short_long, do: Decimal.mult(basis_delta, -1), else: basis_delta)
      change_position(stock, %{basis: Decimal.sub(stock.basis, basis_delta)})
    end)
    |> elem(1)
    |> Enum.map(fn
      %Ecto.Changeset{} = changeset ->
        Repo.insert!(Audits.position_audit_changeset(:update, @system_action_user_id, changeset.data))

        {:ok, position} = Repo.update(changeset)
        position

      %Position{} = position ->
        # Do nothing as this stock was unchanged
        position
    end)
  end

  # When not closing a call/put, just return empty since nothing was done
  defp update_basis!(_position) do
    []
  end

  defp pair_contacts_with_stock(stocks, count, stock_transform_fn) do
    stocks
    |> Enum.reduce({count, []}, fn stock, {count, stocks} ->
      contracts_can_reduce = div(stock.count, 100)
      count_delta = if(contracts_can_reduce > count, do: count, else: contracts_can_reduce)

      stock =
        if count_delta > 0 do
          # If all mode, pass in remaining amount of contracts needed to be satisfied
          stock_transform_fn.(stock, count_delta)
        else
          # unchanged
          stock
        end

      {count - count_delta, [stock | stocks]}
    end)
  end

  defp handle_exercise!(%Position{status: :exercised, count: count, type: call_or_put} = position)
       when call_or_put in ~w[call put]a do
    # Long stock for call, short stock for put
    short_long = if(call_or_put == :call, do: false, else: true)

    position = position |> Repo.preload(:account)

    position
    |> Position.open_related_positions()
    |> Repo.all()
    # Do after retrieval to be able to use index
    |> Enum.reject(fn s ->
      # Can't be used for this option
      s.short != short_long
    end)
    |> Enum.sort_by(fn %Position{count: c} -> c end, &Kernel.>=/2)
    |> handle_exercise_close(position, count * 100)
    |> Enum.map(fn
      %Ecto.Changeset{} = changeset ->
        {:ok, position} =
          if changeset.data.id do
            Repo.insert!(Audits.position_audit_changeset(:update, @system_action_user_id, position))

            Repo.update(changeset)
          else
            Repo.insert!(Audits.position_audit_changeset(:insert, @system_action_user_id, position))

            Repo.insert(changeset)
          end

        position

      %Position{} = position ->
        # Do nothing as this stock was unchanged
        position
    end)
  end

  defp handle_exercise!(_position) do
    []
  end

  defp handle_exercise_close(stocks, position, shares_needed) do
    {shares_uncovered, stocks} =
      stocks
      |> Enum.reduce({shares_needed, []}, fn stock, {shares_needed, stocks} ->
        {stock, shares_covered} =
          if stock.count <= shares_needed do
            {
              change_position(stock, %{
                exit_price: position.strike,
                status: :closed,
                closed_at: position.closed_at
              }),
              stock.count
            }
          else
            {stock, 0}
          end

        {shares_needed - shares_covered, [stock | stocks]}
      end)

    {last_stock, stocks} =
      case stocks do
        [_ | _] ->
          [last_stock | stocks] = Enum.reverse(stocks)
          {last_stock, stocks}

        _ ->
          {nil, stocks}
      end

    cond do
      # Last position hasn't been closed out since it is larger than shares_needed
      shares_uncovered > 0 && match?(%Position{}, last_stock) ->
        new_position =
          Position.duplicate_changeset(last_stock, %{
            count: shares_uncovered,
            status: :closed,
            exit_price: position.strike,
            closed_at: position.closed_at
          })

        [
          new_position,
          change_position(last_stock, %{count: last_stock.count - shares_uncovered}) | stocks
        ]

      # All positions have been closed out and a new one must be created
      shares_uncovered > 0 && match?(%Ecto.Changeset{}, last_stock) ->
        new_position_attrs = Position.to_stock_attrs(last_stock.data) |> Map.put(:short, !last_stock.data.short)

        {:ok, new_position} = create_position(new_position_attrs, %User{id: @system_action_user_id})

        [new_position, last_stock | stocks]

      # There are no stocks at all so the entire position must be created
      shares_uncovered > 0 && last_stock == nil ->
        {short, basis_delta} =
          cond do
            Position.TransType.call?(position.type) ->
              {true, Decimal.mult(position.premium, -1)}

            Position.TransType.put?(position.type) ->
              {false, position.premium}

            true ->
              raise "Unexpected position type of stock: #{inspect(position)}"
          end

        new_position_attrs =
          position
          |> Position.to_stock_attrs()
          |> Map.merge(%{
            short: short,
            opened_at: DateTime.utc_now() |> DateTime.to_date(),
            basis: Decimal.sub(position.strike, basis_delta)
          })

        {:ok, new_position} = create_position(new_position_attrs, %User{id: @system_action_user_id})

        [new_position | stocks]

      # Everything fit perfectly
      shares_uncovered == 0 ->
        [last_stock | stocks]
    end
  end

  @spec delete_position(OptionsTracker.Accounts.Position.t()) ::
          {:ok, Position.t()} | {:error, Ecto.Changeset.t()}
  @doc """
  Deletes a position.

  ## Examples

      iex> delete_position(position, %User{id: 123})
      {:ok, %Position{}}

      iex> delete_position(position, %User{id: 123})
      {:error, %Ecto.Changeset{}}

  """
  def delete_position(%Position{id: id} = position) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(
      :position_audit,
      fn repo, _changes ->
        case from(p in Audits.Position, where: p.position_id == ^id) |> repo.delete_all() do
          {count, nil} -> {:ok, count}
          other -> {:error, other}
        end
      end
    )
    |> Ecto.Multi.delete(:position, position)
    |> Repo.transaction()
    |> case do
      {:ok, %{position: position}} -> {:ok, position}
      {:error, :position, changeset, _} -> {:error, changeset}
      result -> raise "An unexpected failure occurred deleting a position! #{inspect(result)}"
    end
  end

  @spec change_position(OptionsTracker.Accounts.Position.t(), :invalid | map) ::
          Ecto.Changeset.t()
  @doc """
  Returns an `%Ecto.Changeset{}` for tracking position changes.

  ## Examples

      iex> change_position(position)
      %Ecto.Changeset{data: %Position{}}

  """
  def change_position(position, attrs \\ %{})

  def change_position(%Position{status: nil} = position, attrs) do
    Position.open_changeset(position, attrs)
  end

  def change_position(%Position{} = position, attrs) do
    Position.changeset(position, attrs)
  end

  @spec list_position_types :: [{:call, 1} | {:put, 2} | {:stock, 0}, ...]
  def list_position_types() do
    Position.TransType.__enum_map__()
  end

  @spec name_for_position_type(:call | :put | :stock) :: <<_::24, _::_*8>>
  def name_for_position_type(type) do
    Position.TransType.name_for(type)
  end

  @spec list_position_statuses(atom | non_neg_integer) :: [
          {:closed, 1} | {:exercised, 3} | {:open, 0} | {:rolled, 2},
          ...
        ]
  def list_position_statuses(stock_type) when stock_type in [1, :stock] do
    Position.StatusType.__enum_map__()
    |> Enum.reject(fn {status, _value} -> status in [:exercised, :rolled] end)
  end

  def list_position_statuses(_other) do
    Position.StatusType.__enum_map__()
  end

  def position_with_account(%Position{account: %Account{}} = position), do: position

  def position_with_account(%Position{account: _} = position) do
    Repo.preload(position, :account)
  end

  for {status, value} <- Position.StatusType.__enum_map__() do
    def unquote(:"position_status_#{status}")(), do: unquote(value)
    def unquote(:"position_status_#{status}_key")(), do: unquote(status)
  end

  for {type, value} <- Position.TransType.__enum_map__() do
    def unquote(:"position_type_#{type}")(), do: unquote(value)
    def unquote(:"position_type_#{type}_key")(), do: unquote(type)
  end

  def name_for_position_status(status, past_tense \\ false) do
    Position.StatusType.name_for(status, past_tense)
  end
end
