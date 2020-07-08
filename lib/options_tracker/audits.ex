defmodule OptionsTracker.Audits do
  @moduledoc """
  The Audits context.
  """

  import Ecto.Query, warn: false
  alias OptionsTracker.Audits.Position, as: PositionAudit

  @spec position_audit_changeset(
          :insert | :update | :delete,
          -1 | non_neg_integer,
          OptionsTracker.Accounts.Position.t()
        ) :: Ecto.Changeset.t()
  @doc """
  Creates a position audit changeset.

  ## Examples

      iex> position_audit_changeset(:update, 30, %OptionsTracker.Accounts.Position{id: 123, stock: "XYZ", account_id: 3})
      %Ecto.Changeset{}
  """
  def position_audit_changeset(action, user_id, position) do
    attrs = %{
      action: action,
      before: position,
      user_id: user_id,
      position_id: position.id,
      account_id: position.account_id
    }

    %PositionAudit{}
    |> PositionAudit.changeset(attrs)
  end
end
