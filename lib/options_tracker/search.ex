defmodule OptionsTracker.Search do
  alias OptionsTracker.Accounts
  alias OptionsTracker.Accounts.Account

  @schema %{
    search: :string,
    open: :boolean,
    account_ids: {:array, :integer}
  }

  def new(account, params \\ %{})
  def new(%Account{} = account, params), do: new([account], params)

  def new(accounts, params) when is_list(accounts) do
    changeset =
      {%{}, @schema}
      |> Ecto.Changeset.cast(
        params |> Map.put("account_ids", for(a <- accounts, do: a.id)),
        Map.keys(@schema)
      )

    put_in(changeset.changes, Map.merge(%{}, changeset.changes))
  end

  def search(%Ecto.Changeset{changes: params, valid?: true}) do
    Accounts.search_positions(params |> IO.inspect(label: "search params"))
  end
end
