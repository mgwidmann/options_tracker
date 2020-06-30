defmodule OptionsTracker.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias OptionsTracker.Repo

  alias OptionsTracker.Accounts.Account

  @doc """
  Returns the list of accounts.

  ## Examples

      iex> list_accounts()
      [%Account{}, ...]

  """
  def list_accounts do
    Repo.all(Account)
  end

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
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

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
          {:other, 1000} | {:robinhood, 1} | {:tasty_works, 0} | {:td_ameritrade, 2},
          ...
        ]
  def list_account_types() do
    Account.TypeEnum.__enum_map__()
  end

  @spec name_for_type(atom) :: nil | String.t()
  def name_for_type(type) do
    Account.TypeEnum.name_for(type)
  end

  alias OptionsTracker.Accounts.Position

  @doc """
  Returns the list of positions.

  ## Examples

      iex> list_positions()
      [%Position{}, ...]

  """
  def list_positions do
    Repo.all(Position)
  end

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

  @doc """
  Creates a position.

  ## Examples

      iex> create_position(%{field: value})
      {:ok, %Position{}}

      iex> create_position(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_position(attrs \\ %{}) do
    %Position{}
    |> Position.open_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a position.

  ## Examples

      iex> update_position(position, %{field: new_value})
      {:ok, %Position{}}

      iex> update_position(position, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_position(%Position{} = position, attrs) do
    changeset = position |> Position.changeset(attrs)

    if changeset.valid? do
      Repo.transaction(fn ->
        case Repo.update(changeset) do
          {:ok, position} ->
            update_basis!(position)
            position

          {:error, changeset} ->
            {:error, changeset}
        end
      end)
    else
      {:error, changeset}
    end
  end

  @doc """
  Updates any long or short stock positions' basis field which were used as collateral for this position.
  """
  @spec update_basis!(OptionsTracker.Accounts.Position.t()) :: [
          OptionsTracker.Accounts.Position.t()
        ]
  def update_basis!(
        %Position{status: :closed, count: count, type: call_or_put, profit_loss: profit_loss} =
          position
      )
      when call_or_put in ~w[call put]a do
    open_enum = Position.StatusType.__enum_map__()[:open]
    stock_enum = Position.TransType.__enum_map__()[:stock]
    # Long stock for call, short stock for put
    short_long = if(call_or_put == :call, do: false, else: true)
    profit_loss_per_contact = profit_loss / count

    from(p in Position,
      where:
        p.account_id == ^position.account_id and
          p.status == ^open_enum and
          p.stock == ^position.stock and
          p.type == ^stock_enum
    )
    # Apply logic to oldest opened positions first
    |> order_by(asc: :opened_at)
    |> Repo.all()
    # Do after retrieval to be able to use index
    |> Enum.reject(fn s ->
      # Can't be used for this option to lower basis
      s.short != short_long || s.count < 100
    end)
    |> Enum.reduce({count, []}, fn stock, {count, stocks} ->
      contracts_can_reduce = div(stock.count, 100)
      count_delta = if(contracts_can_reduce > count, do: count, else: contracts_can_reduce)

      stock =
        if count_delta > 0 do
          basis_delta = profit_loss_per_contact / stock.count * count_delta
          # short stock positions add to basis instead of lowering basis
          basis_delta = if(short_long, do: -basis_delta, else: basis_delta)
          change_position(stock, %{basis: stock.basis - basis_delta})
        else
          # unchanged
          stock
        end

      {count - count_delta, [stock | stocks]}
    end)
    |> elem(1)
    |> Enum.map(fn
      %Ecto.Changeset{} = changeset ->
        {:ok, position} = Repo.update(changeset)
        position

      %Position{} = position ->
        # Do nothing as this stock was unchanged
        position
    end)
  end

  # When not closing a call/put, just return empty since nothing was done
  def update_basis!(_position) do
    []
  end

  @doc """
  Deletes a position.

  ## Examples

      iex> delete_position(position)
      {:ok, %Position{}}

      iex> delete_position(position)
      {:error, %Ecto.Changeset{}}

  """
  def delete_position(%Position{} = position) do
    Repo.delete(position)
  end

  @spec change_position(
          OptionsTracker.Accounts.Position.t(),
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
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

  @spec list_position_statuses :: [
          {:closed, 1} | {:exercised, 3} | {:open, 0} | {:rolled, 2},
          ...
        ]
  def list_position_statuses() do
    Position.StatusType.__enum_map__()
  end

  def name_for_position_status(status, past_tense \\ false) do
    Position.StatusType.name_for(status, past_tense)
  end
end
