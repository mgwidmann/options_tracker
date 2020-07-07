defmodule OptionsTracker.Fields.Date do
  require Logger

  def type(), do: :date

  def cast(date_string) when is_binary(date_string) do
    case DateTimeParser.parse(date_string) do
      {:ok, date} -> {:ok, date}
      {:error, reason} ->
        Logger.warn("Unable to parse date correctly: #{inspect date_string}, got: #{reason}")
        :error
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
