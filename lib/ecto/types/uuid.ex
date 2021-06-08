if Code.ensure_loaded?(Ecto.ParameterizedType) do
  defmodule Shortcode.Ecto.UUID do
    @moduledoc """
    An Ecto type for UUIDs shortcode with prefix.
    """
    use Ecto.ParameterizedType

    @type t :: binary

    @typedoc "A hex-encoded UUID string."
    @type uuid :: <<_::288>>

    @typedoc "A raw binary representation of a UUID."
    @type raw :: <<_::128>>

    @spec type(any) :: :uuid
    def type(_), do: :uuid

    @spec init(keyword) :: map
    def init(opts), do: Enum.into(opts, %{})

    @spec cast(uuid() | nil, map) :: {:ok, t() | nil} | :error
    def cast(<<_::64, ?-, _::32, ?-, _::32, ?-, _::32, ?-, _::96>> = data, params) do
      prefix = Map.get(params, :prefix)

      Shortcode.to_shortcode(data, prefix)
    end

    def cast(data, _) when is_binary(data) and byte_size(data) > 0 do
      {:ok, data}
    end

    def cast(nil, _), do: {:ok, nil}
    def cast(_, _), do: :error

    @spec load(raw() | nil, function, map) :: {:ok, t() | nil} | :error
    def load(<<_::128>> = uuid, _, params) do
      prefix = Map.get(params, :prefix)

      {:ok, uuid |> Ecto.UUID.cast!() |> Shortcode.to_shortcode!(prefix)}
    end

    def load(<<_::64, ?-, _::32, ?-, _::32, ?-, _::32, ?-, _::96>> = string, _, _) do
      raise ArgumentError,
            "trying to load string UUID as Shortcode.Ecto.UUID: #{inspect(string)}. " <>
              "Maybe you wanted to declare :uuid as your database field?"
    end

    def load(nil, _, _), do: {:ok, nil}
    def load(_, _, _), do: :error

    @spec dump(t() | uuid(), function, map) :: {:ok, raw() | nil} | :error
    def dump(<<_::64, ?-, _::32, ?-, _::32, ?-, _::32, ?-, _::96>> = data, _, _) do
      data
      |> Ecto.UUID.dump()
    end

    def dump(data, dumper, params) when is_binary(data) and byte_size(data) > 0 do
      prefix = Map.get(params, :prefix)

      case Shortcode.to_uuid(data, prefix) do
        {:ok, uuid} -> dump(uuid, dumper, params)
        :error -> :error
      end
    end

    def dump(nil, _, _), do: {:ok, nil}
    def dump(_, _, _), do: :error

    @spec autogenerate(map) :: t()
    def autogenerate(params) do
      prefix = Map.get(params, :prefix)

      Ecto.UUID.generate()
      |> Shortcode.to_shortcode!(prefix)
    end
  end
end
