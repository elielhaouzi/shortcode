if Code.ensure_loaded?(Ecto.ParameterizedType) do
  defmodule Shortcode.Ecto.ID do
    @moduledoc """
    An Ecto type for ids shortcode with prefix.
    """
    use Ecto.ParameterizedType

    @typedoc "A binary string."
    @type t :: binary

    @typedoc "Stored type data"
    @type raw :: non_neg_integer

    @spec init(keyword) :: map
    def init(opts), do: Enum.into(opts, %{})

    @spec type(any) :: :id
    def type(_), do: :id

    @spec cast(t() | raw(), map) :: {:ok, t() | nil} | :error
    def cast(data, params) when is_integer(data) do
      prefix = Map.get(params, :prefix)
      prefix_separator = Map.get(params, :separator)

      Shortcode.to_shortcode(data, prefix, prefix_separator: prefix_separator)
    end

    def cast(data, _) when is_binary(data) and byte_size(data) > 0,
      do: {:ok, data}

    def cast(nil, _), do: {:ok, nil}
    def cast(_, _), do: :error

    @spec load(raw() | nil, function, map) :: {:ok, t() | nil} | :error
    def load(data, _, params) when is_integer(data) do
      prefix = Map.get(params, :prefix)
      prefix_separator = Map.get(params, :separator)

      Shortcode.to_shortcode(data, prefix, prefix_separator: prefix_separator)
    end

    def load(nil, _, _), do: {:ok, nil}
    def load(_, _, _), do: :error

    @spec dump(t() | raw() | nil, function, map) :: {:ok, raw() | nil} | :error
    def dump(data, _, _) when is_integer(data) and data >= 0,
      do: {:ok, data}

    def dump(data, _, params) when is_binary(data) and byte_size(data) > 0 do
      prefix = Map.get(params, :prefix)
      prefix_separator = Map.get(params, :separator)

      Shortcode.to_integer(data, prefix, prefix_separator: prefix_separator)
    end

    def dump(nil, _, _), do: {:ok, nil}
    def dump(_, _, _), do: :error
  end
end
