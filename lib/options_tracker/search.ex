defmodule OptionsTracker.Search do
  alias OptionsTracker.Accounts
  alias OptionsTracker.Accounts.Account

  @schema %{
    search: :string,
    open: :boolean,
    account_ids: {:array, :integer}
  }
  @type t :: %{
          optional(:search) => String.t(),
          optional(:open) => boolean,
          optional(:account_ids) => list(non_neg_integer)
        }

  @spec new(nil | list(Account.t()) | Account.t(), t()) :: map
  def new(account, params \\ %{})
  def new(%Account{} = account, params), do: new([account], params)

  def new(accounts, params) when is_list(accounts) or is_nil(accounts) do
    changeset =
      {%{}, @schema}
      |> Ecto.Changeset.cast(
        params |> Map.put("account_ids", for(a <- accounts || [], do: a.id)),
        Map.keys(@schema)
      )

    put_in(changeset.changes, Map.merge(%{}, changeset.changes))
  end

  @spec search(Ecto.Changeset.t()) :: [Accounts.Position.t()]
  def search(%Ecto.Changeset{changes: params, valid?: true}) do
    Accounts.search_positions(params)
  end
end
