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
    def cast(<<_::288>> = uuid, _), do: {:ok, uuid}

    def cast(shortcode, _) when is_binary(shortcode) and byte_size(shortcode) > 0 do
      {:ok, Shortcode.to_uuid(shortcode)}
    end

    def cast(_, _), do: :error

    @spec load(uuid_string, any, map) :: {:ok, binary}
    def load(<<_::288>> = uuid, _, params) do
      prefix = Map.get(params, :prefix)

      {:ok, Shortcode.to_shortcode(uuid, prefix)}
    end

    def load(_, _, _), do: :error

    @spec dump(any, any, map) :: {:ok, uuid_string} | :error
    def dump(value, _dumper, params), do: cast(value, params)

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
