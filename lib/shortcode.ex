defmodule Shortcode do
  @moduledoc """
  Documentation for `Shortcode`.
  """

  alias Shortcode.Ecto.UUID
  alias Shortcode.Base62

  @prefix_separator "_"

  @doc """
  Convert an hex encoded uuid or an integer to a shortcode with support of prefix.

  ## Examples

      iex> Shortcode.to_shortcode("14366daa-c0f5-0f52-c9ec-e0a0b1e20006", "prefix")
      {:ok, "prefix_C8IF9cqY1HP7GGslHNYLI"}

      iex> Shortcode.to_shortcode(0)
      {:ok, "0"}

      iex> Shortcode.to_shortcode(61)
      {:ok, "Z"}

      iex> Shortcode.to_shortcode("00000000-0000-0000-0000-000000000000")
      {:ok, "0"}

      iex> Shortcode.to_shortcode("ffffffff-ffff-ffff-ffff-ffffffffffff")
      {:ok, "7N42dgm5tFLK9N8MT7fHC7"}

      iex> Shortcode.to_shortcode(Ecto.UUID.bingenerate)
      :error

      iex> Shortcode.to_shortcode("ffffffff-ffff-ffff-ffff-fffffffffffg")
      :error

      iex> Shortcode.to_shortcode("e0a0b1e20006")
      :error

      iex> Shortcode.to_shortcode("-1")
      :error

  """
  @spec to_shortcode(UUID.uuid() | non_neg_integer, nil | binary) :: {:ok, binary} | :error
  def to_shortcode(data, prefix \\ nil)

  def to_shortcode(<<_::64, ?-, _::32, ?-, _::32, ?-, _::32, ?-, _::96>> = uuid, prefix) do
    case Ecto.UUID.cast(uuid) do
      {:ok, uuid} ->
        shortcode =
          uuid
          |> String.replace("-", "")
          |> String.to_integer(16)
          |> Base62.encode()

        shortcode = if prefix, do: "#{prefix}#{@prefix_separator}#{shortcode}", else: shortcode

        {:ok, shortcode}

      :error ->
        :error
    end
  end

  def to_shortcode(integer, prefix) when is_integer(integer) and integer >= 0 do
    shortcode = integer |> Base62.encode()

    shortcode = if prefix, do: "#{prefix}#{@prefix_separator}#{shortcode}", else: shortcode

    {:ok, shortcode}
  end

  def to_shortcode(_, _), do: :error

  @doc """
  Same as `to_shortcode/2` but raises `ArgumentError` on invalid arguments.
  """
  @spec to_shortcode!(any, nil | binary) :: binary
  def to_shortcode!(data, prefix \\ nil) do
    case to_shortcode(data, prefix) do
      {:ok, shortcode} -> shortcode
      :error -> raise ArgumentError, "cannot convert #{inspect(data)} to shortcode"
    end
  end

  @doc """
  Convert a shortcode to a uuid.

  ## Examples

      # iex> Shortcode.to_uuid("0")
      # {:ok, "00000000-0000-0000-0000-000000000000"}

      # iex> Shortcode.to_uuid("C8IF9cqY1HP7GGslHNYLI")
      # {:ok, "14366daa-c0f5-0f52-c9ec-e0a0b1e20006"}

      iex> Shortcode.to_uuid("prefix_C8IF9cqY1HP7GGslHNYLI", "prefix")
      {:ok, "14366daa-c0f5-0f52-c9ec-e0a0b1e20006"}

      # iex> Shortcode.to_uuid("pre_fix_C8IF9cqY1HP7GGslHNYLI", "pre_fix")
      # {:ok, "14366daa-c0f5-0f52-c9ec-e0a0b1e20006"}

      # iex> Shortcode.to_uuid("foo_C8IF9cqY1HP7GGslHNYLI", "bar")
      # :error

      # iex> Shortcode.to_uuid("7N42dgm5tFLK9N8MT7fHC8")
      # :error

      # iex> Shortcode.to_uuid(Ecto.UUID.bingenerate())
      # :error

      # iex> Shortcode.to_uuid("")
      # :error

  """
  @spec to_uuid(binary | any, binary | nil) :: {:ok, UUID.uuid()} | :error
  def to_uuid(shortcode, prefix \\ nil)

  def to_uuid(shortcode, nil) when is_binary(shortcode) and byte_size(shortcode) > 0 do
    with {:ok, int_shortcode} <- Base62.decode(shortcode),
         hex_shortcode <- Integer.to_string(int_shortcode, 16),
         {:valid_length?, true} <- {:valid_length?, String.length(hex_shortcode) <= 32} do
      <<
        part1::binary-size(8),
        part2::binary-size(4),
        part3::binary-size(4),
        part4::binary-size(4),
        part5::binary-size(12)
      >> =
        hex_shortcode
        |> String.pad_leading(32, ["0"])
        |> String.downcase()

      Ecto.UUID.cast("#{part1}-#{part2}-#{part3}-#{part4}-#{part5}")
    else
      _ ->
        :error
    end
  end

  def to_uuid(shortcode, prefix) when is_binary(shortcode) do
    prefix_with_separator = prefix <> @prefix_separator

    shortcode
    |> String.split_at(String.length(prefix_with_separator))
    |> case do
      {^prefix_with_separator, data} -> to_uuid(data, nil)
      _ -> :error
    end
  end

  def to_uuid(_, _), do: :error

  @doc """
  Same as `to_uuid/1` but raises `ArgumentError` on invalid arguments.
  """
  @spec to_uuid!(binary, binary | nil) :: UUID.uuid()
  def to_uuid!(shortcode, prefix \\ nil) do
    case to_uuid(shortcode, prefix) do
      {:ok, uuid} -> uuid
      :error -> raise ArgumentError, "cannot convert shortcode #{inspect(shortcode)} to uuid"
    end
  end

  @doc """
  Convert a shortcode to an integer.

  ## Examples

      iex> Shortcode.to_integer("A")
      {:ok, 36}

      iex> Shortcode.to_integer("0")
      {:ok, 0}

      iex> Shortcode.to_integer("C8IF9cqY1HP7GGslHNYLI")
      {:ok, 26867168257211004681214735068979920902}

      iex> Shortcode.to_integer("prefix_C8IF9cqY1HP7GGslHNYLI", "prefix")
      {:ok, 26867168257211004681214735068979920902}

      iex> Shortcode.to_integer("foo_C8IF9cqY1HP7GGslHNYLI", "bar")
      :error

      iex> Shortcode.to_integer(Ecto.UUID.bingenerate)
      :error

      iex> Shortcode.to_integer(1)
      :error

  """
  @spec to_integer(binary, binary | nil) :: {:ok, integer} | :error
  def to_integer(shortcode, prefix \\ nil)

  def to_integer(shortcode, nil) when is_binary(shortcode) do
    try do
      Base62.decode!(shortcode)
    rescue
      _ -> :error
    else
      integer -> {:ok, integer}
    end
  end

  def to_integer(shortcode, prefix) when is_binary(shortcode) do
    shortcode
    |> String.split(@prefix_separator, parts: 2)
    |> case do
      [^prefix, data] -> to_integer(data, nil)
      _ -> :error
    end
  end

  def to_integer(_, _), do: :error

  @doc """
  Same as `to_integer/1` but raises `ArgumentError` on invalid arguments.
  """
  @spec to_integer!(binary, binary | nil) :: integer
  def to_integer!(shortcode, prefix) do
    case to_integer(shortcode, prefix) do
      {:ok, integer} -> integer
      :error -> raise ArgumentError, "cannot convert shortcode #{inspect(shortcode)} to integer"
    end
  end

  @doc false
  @spec prefix_separator :: binary
  def prefix_separator(), do: @prefix_separator
end
