defmodule OptionsTracker.Enum do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  defmacro defenum({:__aliases__, _, [name]}, enum_list, [do: block]) do
    name = Module.concat(__CALLER__.module, name)
    helper_methods = quote unquote: false do
      for {type, value} <- @enum do
        def unquote(:"#{type}")(), do: unquote(value)
        def unquote(:"#{type}_key")(), do: unquote(type)
        def unquote(:"#{type}?")(val) when val in [unquote(type), unquote(to_string(type)), unquote(value), unquote(to_string(value))], do: true
        def unquote(:"#{type}?")(_val), do: false
      end
    end

    quote do
      defmodule unquote(name) do
        @enum unquote(enum_list)
        use EctoEnum, @enum

        unquote(helper_methods)

        unquote(block)
      end
      alias unquote(name)
    end
  end
end
