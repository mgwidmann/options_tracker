# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     OptionsTracker.Repo.insert!(%OptionsTracker.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias OptionsTracker.Users
alias OptionsTracker.Users.User
alias OptionsTracker.Accounts.Account
alias OptionsTracker.Accounts.Position
alias OptionsTracker.Repo

user = Users.get_user_by_email("admin@gmail.com")

user =
  if user == nil do
    %User{
      id: 1,
      email: "admin@gmail.com",
      admin?: true,
      confirmed_at: DateTime.utc_now() |> DateTime.truncate(:second),
      hashed_password: Bcrypt.hash_pwd_salt("adminpassword")
    }
    |> Repo.insert!()
    |> Repo.preload(:accounts)
  else
    user
  end

{rh, tw} =
  if user.accounts == [] do
    rh =
      %Account{
        broker_name: nil,
        cash: Decimal.from_float(2_000.00),
        exercise_fee: Decimal.from_float(0.00),
        name: "Robinhood",
        opt_close_fee: Decimal.from_float(0.00),
        opt_open_fee: Decimal.from_float(0.00),
        stock_close_fee: Decimal.from_float(0.00),
        stock_open_fee: Decimal.from_float(0.00),
        type: :robinhood,
        user_id: user.id
      }
      |> Repo.insert!()

    tw =
      %Account{
        broker_name: nil,
        cash: Decimal.from_float(4_000.00),
        exercise_fee: Decimal.from_float(5.00),
        name: "TW Margin",
        opt_close_fee: Decimal.from_float(0.14),
        opt_open_fee: Decimal.from_float(1.15),
        stock_close_fee: Decimal.from_float(0.00),
        stock_open_fee: Decimal.from_float(0.00),
        type: :tasty_works,
        user_id: user.id
      }
      |> Repo.insert!()

    {rh, tw}
  else
    rh = user.accounts |> Enum.find(fn a -> a.name == "Robinhood" end)
    tw = user.accounts |> Enum.find(fn a -> a.name == "TW Margin" end)
    {rh, tw}
  end

[
  %Position{
    account_id: rh.id,
    basis: 16.3,
    closed_at: nil,
    count: 100,
    exit_price: nil,
    exit_strategy: nil,
    expires_at: nil,
    fees: 0.0,
    id: 10,
    notes: nil,
    opened_at: ~D[2020-07-07],
    premium: nil,
    profit_loss: nil,
    short: false,
    spread_width: nil,
    status: :open,
    stock: "SPCE",
    strike: 19.0,
    type: :stock
  },
  %Position{
    account_id: rh.id,
    basis: nil,
    closed_at: nil,
    count: 1,
    exit_price: nil,
    exit_strategy: nil,
    expires_at: ~D[2020-07-10],
    fees: 0.0,
    id: 18,
    notes: nil,
    opened_at: ~D[2020-07-02],
    premium: 0.49,
    profit_loss: nil,
    short: true,
    spread_width: nil,
    status: :open,
    stock: "SPCE",
    strike: 17.0,
    type: :call
  },
  %Position{
    account_id: rh.id,
    basis: nil,
    closed_at: ~D[2020-05-15],
    count: 1,
    exit_price: 0.0,
    exit_strategy: nil,
    expires_at: ~D[2020-05-15],
    fees: 0.0,
    id: 9,
    notes: nil,
    opened_at: ~D[2020-05-11],
    premium: 1.08,
    profit_loss: 108.0,
    short: true,
    spread_width: nil,
    status: :exercised,
    stock: "SPCE",
    strike: 19.0,
    type: :put
  },
  %Position{
    account_id: rh.id,
    basis: nil,
    closed_at: ~D[2020-05-19],
    count: 1,
    exit_price: 0.16,
    exit_strategy: nil,
    expires_at: ~D[2020-05-22],
    fees: 0.0,
    id: 11,
    notes: nil,
    opened_at: ~D[2020-05-18],
    premium: 0.3,
    profit_loss: 14.0,
    short: true,
    spread_width: nil,
    status: :closed,
    stock: "SPCE",
    strike: 17.5,
    type: :call
  },
  %Position{
    account_id: rh.id,
    basis: nil,
    closed_at: ~D[2020-05-21],
    count: 1,
    exit_price: 0.27,
    exit_strategy: nil,
    expires_at: ~D[2020-05-29],
    fees: 0.0,
    id: 12,
    notes: nil,
    opened_at: ~D[2020-05-19],
    premium: 0.42,
    profit_loss: 15.0,
    short: true,
    spread_width: nil,
    status: :closed,
    stock: "SPCE",
    strike: 18.0,
    type: :call
  },
  %Position{
    account_id: rh.id,
    basis: nil,
    closed_at: ~D[2020-06-03],
    count: 1,
    exit_price: 1.36,
    exit_strategy: nil,
    expires_at: ~D[2020-07-17],
    fees: 0.0,
    id: 13,
    notes: nil,
    opened_at: ~D[2020-05-21],
    premium: 1.55,
    profit_loss: 19.0,
    short: true,
    spread_width: nil,
    status: :closed,
    stock: "SPCE",
    strike: 18.0,
    type: :call
  },
  %Position{
    account_id: rh.id,
    basis: nil,
    closed_at: ~D[2020-06-12],
    count: 1,
    exit_price: 0.02,
    exit_strategy: nil,
    expires_at: ~D[2020-06-12],
    fees: 0.0,
    id: 14,
    notes: nil,
    opened_at: ~D[2020-06-03],
    premium: 0.45,
    profit_loss: 43.0,
    short: true,
    spread_width: nil,
    status: :closed,
    stock: "SPCE",
    strike: 17.0,
    type: :call
  },
  %Position{
    account_id: rh.id,
    basis: nil,
    closed_at: ~D[2020-06-19],
    count: 1,
    exit_price: 0.01,
    exit_strategy: nil,
    expires_at: ~D[2020-06-19],
    fees: 0.0,
    id: 15,
    notes: nil,
    opened_at: ~D[2020-06-15],
    premium: 0.22,
    profit_loss: 21.0,
    short: true,
    spread_width: nil,
    status: :closed,
    stock: "SPCE",
    strike: 16.5,
    type: :call
  },
  %Position{
    account_id: rh.id,
    basis: nil,
    closed_at: ~D[2020-06-26],
    count: 1,
    exit_price: 0.01,
    exit_strategy: nil,
    expires_at: ~D[2020-06-26],
    fees: 0.0,
    id: 16,
    notes: nil,
    opened_at: ~D[2020-06-19],
    premium: 0.25,
    profit_loss: 24.0,
    short: true,
    spread_width: nil,
    status: :closed,
    stock: "SPCE",
    strike: 17.0,
    type: :call
  },
  %Position{
    account_id: rh.id,
    basis: nil,
    closed_at: ~D[2020-07-02],
    count: 1,
    exit_price: 0.04,
    exit_strategy: nil,
    expires_at: ~D[2020-07-02],
    fees: 0.0,
    id: 17,
    notes: nil,
    opened_at: ~D[2020-06-26],
    premium: 0.3,
    profit_loss: 26.0,
    short: true,
    spread_width: nil,
    status: :closed,
    stock: "SPCE",
    strike: 17.0,
    type: :call
  }
]
|> Enum.each(fn position ->
  Repo.insert!(position)
end)
