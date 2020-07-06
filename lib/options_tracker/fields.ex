defmodule OptionsTracker.Fields.Date do
  def type(), do: :date

  def cast(date_string) when is_binary(date_string) do
    case DateTimeParser.parse(date_string) do
      {:ok, date} -> {:ok, date}
      {:error, _reason} -> :error
    end
  end
  def cast(%Date{} = date), do: {:ok, date}
  def cast(_), do: :error

  def load(date) do
    {:ok, date}
  end

  def dump(date) do
    {:ok, date}
  end
end
