defmodule OptionsTrackerWeb.Components.RadioButtonComponent do
  use OptionsTrackerWeb, :live_component

  def is_button_on?(%{params: params, data: data}, name) do
    value = params[name] || params[to_string(name)] || Map.get(data, name)

    if is_binary(value) do
      value != "" && value != "false"
    else
      value
    end
  end
end
