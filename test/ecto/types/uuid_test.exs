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

  describe "cast/1" do
    test "when the prefix key is not set" do
      uuid = Ecto.UUID.generate()
      shortcode = uuid |> Shortcode.to_shortcode()
      assert {:ok, ^uuid} = EctoTypeShortcodeUUID.cast(shortcode, %{})
    end

    test "when the prefix key set" do
      uuid = Ecto.UUID.generate()
      shortcode = uuid |> Shortcode.to_shortcode()
      assert {:ok, ^uuid} = EctoTypeShortcodeUUID.cast(shortcode, %{prefix: "prefix"})
    end

    test "with a valid shortcode returns an :ok tuple" do
      uuid = Ecto.UUID.generate()
      shortcode = uuid |> Shortcode.to_shortcode()
      assert {:ok, ^uuid} = EctoTypeShortcodeUUID.cast(shortcode, %{})
    end

    test "with a valid uuid_string returns an :ok tuple" do
      uuid = Ecto.UUID.generate()

      assert {:ok, ^uuid} = EctoTypeShortcodeUUID.cast(uuid, %{})
    end

    test "with an invalid shortcode returns an :error tuple" do
      assert :error = EctoTypeShortcodeUUID.cast("", %{})
    end

    test "with an invalid type returns an :error tuple" do
      assert :error = EctoTypeShortcodeUUID.cast(1, %{})
    end
  end

  describe "load/1" do
    test "with a valid uuid without prefix returns an :ok tuple" do
      uuid = Ecto.UUID.generate()
      shortcode = uuid |> Shortcode.to_shortcode()
      assert {:ok, ^shortcode} = EctoTypeShortcodeUUID.load(uuid, {}, %{})
    end

    test "with a valid uuid with a prefix returns an :ok tuple" do
      prefix = "prefix"
      uuid = Ecto.UUID.generate()
      shortcode = uuid |> Shortcode.to_shortcode(prefix)
      assert {:ok, ^shortcode} = EctoTypeShortcodeUUID.load(uuid, {}, %{prefix: prefix})
    end

    test "with an invalid uuid returns an :error tuple" do
      assert :error = EctoTypeShortcodeUUID.load(1, {}, %{})
    end
  end

  describe "dump/1" do
    test "with an valid shortcode without prefix returns a uuid_string" do
      uuid = Ecto.UUID.generate()
      shortcode = uuid |> Shortcode.to_shortcode()
      assert {:ok, ^uuid} = EctoTypeShortcodeUUID.dump(shortcode, {}, %{})
    end

    test "with an valid shortcode with prefix returns a uuid_string" do
      uuid = Ecto.UUID.generate()
      shortcode = uuid |> Shortcode.to_shortcode()
      assert {:ok, ^uuid} = EctoTypeShortcodeUUID.dump(shortcode, {}, %{})
    end

    test "when the param is not valid returns an error" do
      assert :error = EctoTypeShortcodeUUID.dump("", {}, %{})
      assert :error = EctoTypeShortcodeUUID.dump(1, {}, %{})
    end
  end
end
