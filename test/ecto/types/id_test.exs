defmodule Shortcode.Ecto.IDTest do
  use ExUnit.Case, async: true
  alias Shortcode.Ecto.ID, as: EctoTypeShortcodeID

  defmodule Schema do
    use Ecto.Schema

    @primary_key {:id, EctoTypeShortcodeID, prefix: "sch"}
    embedded_schema do
    end
  end

  describe "cast/1" do
    test "when the prefix key is not set" do
      id = 1
      shortcode = id |> Shortcode.to_shortcode()
      assert {:ok, ^id} = EctoTypeShortcodeID.cast(shortcode, %{})
    end

    test "when the prefix key set" do
      id = 1
      shortcode = id |> Shortcode.to_shortcode()
      assert {:ok, ^id} = EctoTypeShortcodeID.cast(shortcode, %{prefix: "prefix"})
    end

    test "with a valid shortcode returns an :ok tuple" do
      id = 1
      shortcode = id |> Shortcode.to_shortcode()
      assert {:ok, ^id} = EctoTypeShortcodeID.cast(shortcode, %{})
    end

    test "with a positive integer returns an :ok tuple" do
      assert {:ok, 0} = EctoTypeShortcodeID.cast(0, %{})
      assert {:ok, 1} = EctoTypeShortcodeID.cast(1, %{})
    end

    test "with an negative integer returns an :error tuple" do
      assert :error = EctoTypeShortcodeID.cast(-1, %{})
    end

    test "with an invalid type returns an :error tuple" do
      assert :error = EctoTypeShortcodeID.cast("", %{})
    end

    test "with nil" do
      assert {:ok, nil} = EctoTypeShortcodeID.cast(nil, %{autogenerate: true})
      assert :error = EctoTypeShortcodeID.cast(nil, %{autogenerate: false})
    end
  end

  describe "load/1" do
    test "with a valid integer without prefix returns an :ok tuple" do
      id = 0
      shortcode = id |> Shortcode.to_shortcode()
      assert {:ok, ^shortcode} = EctoTypeShortcodeID.load(id, {}, %{})
    end

    test "with a valid integer with a prefix returns an :ok tuple" do
      prefix = "prefix"
      id = 0
      shortcode = id |> Shortcode.to_shortcode(prefix)
      assert {:ok, ^shortcode} = EctoTypeShortcodeID.load(id, {}, %{prefix: prefix})
    end

    test "with an negative integer returns an :error tuple" do
      assert :error = EctoTypeShortcodeID.load(-1, {}, %{})
    end
  end

  describe "dump/1" do
    test "with an valid shortcode without prefix returns a uuid_string" do
      id = 1
      shortcode = id |> Shortcode.to_shortcode()
      assert {:ok, ^id} = EctoTypeShortcodeID.dump(shortcode, {}, %{})
    end

    test "with an valid shortcode with prefix returns a uuid_string" do
      id = 0
      shortcode = id |> Shortcode.to_shortcode()
      assert {:ok, ^id} = EctoTypeShortcodeID.dump(shortcode, {}, %{})
    end

    test "when the param is not valid returns an error" do
      assert :error = EctoTypeShortcodeID.dump(-1, {}, %{})
      assert :error = EctoTypeShortcodeID.dump("", {}, %{})
    end
  end
end
