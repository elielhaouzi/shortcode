if Code.ensure_loaded?(Ecto.ParameterizedType) do
  defmodule Shortcode.Ecto.UUID do
    @moduledoc """
    An Ecto type for UUIDs shortcode with prefix.
    """
    use Ecto.ParameterizedType

    @typedoc """
    A hex-encoded UUID string.
    """
    @type uuid_string :: <<_::288>>

    @spec type(any) :: :uuid
    def type(_), do: :uuid

    @spec init(keyword()) :: map()
    def init(opts) do
      validate_opts!(opts)

      Enum.into(opts, %{})
    end

    @spec cast(binary, map) :: {:ok, uuid_string} | :error
    def cast(<<_::288>> = uuid, params) do
      prefix = Map.get(params, :prefix)

      {:ok, Shortcode.to_shortcode(uuid, prefix)}
    end

    def cast(shortcode, _) when is_binary(shortcode) and byte_size(shortcode) > 0,
      do: {:ok, shortcode}

    def cast(nil, _), do: {:ok, nil}

    def cast(_, _), do: :error

    @spec load(uuid_string, function, map) :: {:ok, binary | nil}
    def load(<<_::288>> = uuid, _, params) do
      prefix = Map.get(params, :prefix)

      {:ok, Shortcode.to_shortcode(uuid, prefix)}
    end

    def load(nil, _, _), do: {:ok, nil}

    def load(_, _, _), do: :error

    @spec dump(any, function, map) :: {:ok, uuid_string | nil} | :error
    def dump(<<_::288>> = uuid, _, _), do: {:ok, uuid}

    def dump(shortcode, _, _)
        when is_binary(shortcode) and byte_size(shortcode) > 0 do
      {:ok, Shortcode.to_uuid(shortcode)}
    end

    def dump(nil, _, _), do: {:ok, nil}

    def dump(_, _, _), do: :error

    @spec autogenerate(map) :: binary
    def autogenerate(params) do
      prefix = Map.get(params, :prefix)

      Ecto.UUID.generate()
      |> Shortcode.to_shortcode(prefix)
    end

    defp validate_opts!(opts) do
      prefix = opts |> Keyword.get(:prefix)

      if not is_nil(prefix) and String.contains?(prefix, Shortcode.prefix_separator()) do
        raise ArgumentError, "prefix cannot contain \"#{Shortcode.prefix_separator()}\""
      end
    end
  end
end
