defmodule Shortcode.Ecto.UUIDTest do
  use ExUnit.Case, async: true
  alias Shortcode.Ecto.UUID, as: EctoTypeShortcodeUUID

  defmodule Schema do
    use Ecto.Schema

    @primary_key {
      :id,
      EctoTypeShortcodeUUID,
      prefix: "sch", autogenerate: true
    }
    embedded_schema do
    end
  end

  describe "cast/2" do
    test "with a hex-encoded uuid without a prefix, returns an {:ok, shortcode} tuple" do
      uuid = Ecto.UUID.generate()
      shortcode = Shortcode.to_shortcode!(uuid)
      assert {:ok, ^shortcode} = EctoTypeShortcodeUUID.cast(uuid, %{})
    end

    test "with a hex-encoded uuid with a prefix, returns an {:ok, shortcode} tuple" do
      uuid = Ecto.UUID.generate()
      prefix = "prefix"
      shortcode = Shortcode.to_shortcode!(uuid, prefix)
      assert {:ok, ^shortcode} = EctoTypeShortcodeUUID.cast(uuid, %{prefix: prefix})
    end

    test "with a valid shortcode returns an :ok tuple" do
      uuid = Ecto.UUID.generate()
      shortcode = Shortcode.to_shortcode!(uuid)
      assert {:ok, ^shortcode} = EctoTypeShortcodeUUID.cast(shortcode, %{})
    end

    test "with nil" do
      assert {:ok, nil} = EctoTypeShortcodeUUID.cast(nil, %{})
    end

    test "with a shortcode that can't be converted back to a valid hex-encoded uuid, returns an :ok tuple" do
      invalid_hex_encoded_uuid_shortcode = "7N42dgm5tFLK9N8MT7fHC8"

      assert {:ok, ^invalid_hex_encoded_uuid_shortcode} =
               EctoTypeShortcodeUUID.cast(invalid_hex_encoded_uuid_shortcode, %{})
    end

    test "with an invalid hex-encoded uuid, returns an error atom" do
      assert :error = EctoTypeShortcodeUUID.cast("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaag", %{})
    end

    test "with an invalid shortcode returns an :error tuple" do
      assert :error = EctoTypeShortcodeUUID.cast("", %{})
    end

    test "with an invalid type returns an :error tuple" do
      assert :error = EctoTypeShortcodeUUID.cast(1, %{})
    end
  end

  describe "load/3" do
    test "with a valid raw binary uuid without prefix returns an :ok tuple" do
      raw_uuid = Ecto.UUID.bingenerate()
      uuid = Ecto.UUID.cast!(raw_uuid)
      shortcode = Shortcode.to_shortcode!(uuid)
      assert {:ok, ^shortcode} = EctoTypeShortcodeUUID.load(raw_uuid, fn -> :noop end, %{})
    end

    test "with a valid raw binary uuid with a prefix returns an :ok tuple" do
      raw_uuid = Ecto.UUID.bingenerate()
      uuid = Ecto.UUID.cast!(raw_uuid)
      prefix = "prefix"
      shortcode = Shortcode.to_shortcode!(uuid, prefix)

      assert {:ok, ^shortcode} =
               EctoTypeShortcodeUUID.load(raw_uuid, fn -> :noop end, %{prefix: prefix})
    end

    test "with nil returns an :ok nil tuple" do
      assert {:ok, nil} = EctoTypeShortcodeUUID.load(nil, fn -> :noop end, %{})
    end

    test "with an hex-encoded uuid raises an ArgumentError" do
      uuid = Ecto.UUID.generate()

      assert_raise ArgumentError, fn ->
        EctoTypeShortcodeUUID.load(uuid, fn -> :noop end, %{})
      end
    end

    test "with an invalid data returns an :error tuple" do
      assert :error = EctoTypeShortcodeUUID.load("", fn -> :noop end, %{})
      assert :error = EctoTypeShortcodeUUID.load(1, fn -> :noop end, %{})
    end
  end

  describe "dump/3" do
    test "with a valid hex-encoded uuid without prefix, returns an :ok, raw_binary uuid tuple" do
      raw_uuid = Ecto.UUID.bingenerate()
      uuid = Ecto.UUID.cast!(raw_uuid)
      assert {:ok, ^raw_uuid} = EctoTypeShortcodeUUID.dump(uuid, fn -> :noop end, %{})
    end

    test "with an valid shortcode with prefix returns a uuid_string" do
      raw_uuid = Ecto.UUID.bingenerate()
      uuid = Ecto.UUID.cast!(raw_uuid)
      assert {:ok, ^raw_uuid} = EctoTypeShortcodeUUID.dump(uuid, fn -> :noop end, %{})
    end

    test "with a valid shortcode, returns an :ok, raw_binary uuid tuple" do
      raw_uuid = Ecto.UUID.bingenerate()
      uuid = Ecto.UUID.cast!(raw_uuid)
      shortcode = Shortcode.to_shortcode!(uuid)
      assert {:ok, ^raw_uuid} = EctoTypeShortcodeUUID.dump(shortcode, fn -> :noop end, %{})
    end

    test "with nil returns a :ok nil tuple" do
      assert {:ok, nil} = EctoTypeShortcodeUUID.dump(nil, fn -> :noop end, %{})
    end

    test "with a shortcode that can't be converted back to a valid hex-encoded uuid, returns an :error" do
      assert :error = EctoTypeShortcodeUUID.dump("7N42dgm5tFLK9N8MT7fHC8", fn -> :noop end, %{})
    end

    test "with raw binary uuid, returns an :error" do
      assert :error = EctoTypeShortcodeUUID.dump(Ecto.UUID.bingenerate(), fn -> :noop end, %{})
    end

    test "when the data is not valid, returns an error" do
      assert :error = EctoTypeShortcodeUUID.dump("", fn -> :noop end, %{})
      assert :error = EctoTypeShortcodeUUID.dump(1, fn -> :noop end, %{})
    end
  end
end
