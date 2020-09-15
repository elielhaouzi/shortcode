# Shortcode

An Ecto type for UUIDs and ID displayed as shortcode with support of prefix 'à la Stripe'.

## Installation

Shortcode is published on [Hex](https://hex.pm/packages/shortcode). The package can be installed
by adding `shortcode` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:shortcode, "~> 0.1.0"}
  ]
end
```

The docs can be found at [https://hexdocs.pm/shortcode](https://hexdocs.pm/shortcode).

## Usage

You can use Shortcode UUID or Shortcode id for regular or primary key fields.

```elixir
defmodule RequestUUID do
  use Ecto.Schema

  schema "request" do
    field :uuid, Shortcode.Ecto.UUID
    field :autogenerated_uuid, Shortcode.Ecto.UUID, autogenerate: true
  end
end

defmodule RequestID do
  use Ecto.Schema

  schema "request" do
    field :request_id, Shortcode.Ecto.ID
  end
end
```

```elixir
defmodule MyApp.UserWithUUID do
  use Ecto.Schema

  @primary_key {:id, Shortcode.Ecto.UUID, prefix: "usr", autogenerate: true}
  schema "users" do
  end
end

defmodule MyApp.UserWithID do
  use Ecto.Schema

  @primary_key {:id, Shortcode.Ecto.ID, prefix: "usr", autogenerate: true}
  schema "users" do
  end
end
```