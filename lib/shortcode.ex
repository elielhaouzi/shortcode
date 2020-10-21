defmodule Shortcode do
  @moduledoc """
  Documentation for `Shortcode`.
  """

  @alphabet "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
  @base String.length(@alphabet)
  @prefix_separator "_"

  @doc """
  Convert an uuid or an integer to a shortcode with support of prefix.

  ## Examples

      iex> Shortcode.to_shortcode(0)
      "0"

      iex> Shortcode.to_shortcode(61)
      "Z"

      iex> Shortcode.to_shortcode("00000000-0000-0000-0000-000000000000")
      "0"

      iex> Shortcode.to_shortcode("14366daa-c0f5-0f52-c9ec-e0a0b1e20006")
      "C8IF9cqY1HP7GGslHNYLI"

      iex> Shortcode.to_shortcode("14366daa-c0f5-0f52-c9ec-e0a0b1e20006", "prefix")
      "prefix_C8IF9cqY1HP7GGslHNYLI"

  """
  @spec to_shortcode(<<_::288>> | non_neg_integer, nil | binary) :: binary
  def to_shortcode(uuid, prefix \\ nil)

  def to_shortcode(<<_::288>> = uuid, prefix) do
    shortcode =
      uuid
      |> String.replace("-", "")
      |> String.to_integer(16)
      |> to_string(@alphabet, @base)

    if prefix, do: "#{prefix}#{@prefix_separator}#{shortcode}", else: shortcode
  end

  def to_shortcode(integer, prefix) when is_integer(integer) and integer >= 0 do
    shortcode = integer |> to_string(@alphabet, @base)

    if prefix, do: "#{prefix}#{@prefix_separator}#{shortcode}", else: shortcode
  end

  @doc """
  Convert a shortcode to a uuid.

  ## Examples

      iex> Shortcode.to_uuid("")
      ** (FunctionClauseError) no function clause matching in Shortcode.to_uuid/1

      iex> Shortcode.to_uuid("0")
      "00000000-0000-0000-0000-000000000000"

      iex> Shortcode.to_uuid("C8IF9cqY1HP7GGslHNYLI")
      "14366daa-c0f5-0f52-c9ec-e0a0b1e20006"

      iex> Shortcode.to_uuid("prefix_C8IF9cqY1HP7GGslHNYLI")
      "14366daa-c0f5-0f52-c9ec-e0a0b1e20006"

  """
  @spec to_uuid(binary) :: <<_::288>>
  def to_uuid(shortcode) when is_binary(shortcode) and byte_size(shortcode) > 0 do
    <<
      part1::binary-size(8),
      part2::binary-size(4),
      part3::binary-size(4),
      part4::binary-size(4),
      part5::binary-size(12)
    >> =
      shortcode
      |> String.split(@prefix_separator)
      |> List.last()
      |> to_integer()
      |> Integer.to_string(16)
      |> String.pad_leading(32, ["0"])
      |> String.downcase()

    Ecto.UUID.cast!("#{part1}-#{part2}-#{part3}-#{part4}-#{part5}")
  end

  @doc """
  Convert a shortcode to an integer.

  ## Examples

      iex> Shortcode.to_integer("A")
      36

      iex> Shortcode.to_integer("0")
      0

      iex> Shortcode.to_integer("C8IF9cqY1HP7GGslHNYLI")
      26867168257211004681214735068979920902

      iex> Shortcode.to_integer("prefix_C8IF9cqY1HP7GGslHNYLI")
      26867168257211004681214735068979920902

  """
  @spec to_integer(binary) :: integer
  def to_integer(shortcode) do
    to_integer(shortcode, @alphabet, @base, @prefix_separator)
  end

  @spec to_integer(binary, binary, non_neg_integer, nil | binary) :: any
  defp to_integer(shortcode, alphabet, base, prefix_separator)
       when is_binary(shortcode) and is_binary(prefix_separator) do
    shortcode
    |> String.split(prefix_separator)
    |> List.last()
    |> to_integer(alphabet, base, nil)
  end

  defp to_integer(string, alphabet, base, nil)
       when is_binary(string) and is_binary(alphabet) do
    String.codepoints(string)
    |> Enum.reduce(0, fn letter, acc ->
      acc * base + (:binary.match(alphabet, letter) |> elem(0))
    end)
  end

  @spec prefix_separator :: binary
  def prefix_separator() do
    @prefix_separator
  end

  defp to_string(integer, alphabet, base)
       when is_integer(integer) and is_binary(alphabet) and is_integer(base) do
    to_string(integer, "", alphabet, base)
  end

  defp to_string(integer, "", alphabet, _base) when is_integer(integer) and integer == 0 do
    "#{String.at(alphabet, 0)}"
  end

  defp to_string(integer, acc, _alphabet, _base) when is_integer(integer) and integer <= 0 do
    acc
  end

  defp to_string(integer, acc, alphabet, base)
       when is_number(integer) and integer >= 0 and is_binary(acc) and is_binary(alphabet) and
              is_integer(base) do
    remainder = rem(integer, base)

    to_string(
      div(integer - remainder, base),
      "#{String.at(alphabet, remainder)}#{acc}",
      alphabet,
      base
    )
  end
end
