# Restarter

The "let it fail" philosophy enabled by Erlang supervision trees is powerful. Sometimes, though, `Supervisor` restart strategies are not enough; something that relies on an external service may fail consistently for an extended period of time, overwhelming the `max_restarts` and propagating the error up the supervision tree. In some cases you may not want such an error to take down your entire application.

The `Restarter` allows you to set a retry interval; the child will be restarted for indefinitely, every configurable amount of time. 




## Installation

1. Add `restarter` to your list of dependencies in `mix.exs`:

```elixir
def deps do
[{:restarter, "~> 0.1.0"}]
end
```

2. Ensure `restarter` is deployed with your application:

```elixir
def application do
[applications: [:restarter]]
end
```

## Usage

To try out in `iex`, given:

```
defmodule MyGenServer do
  use GenServer

  def start_link arg do
    GenServer.start_link(__MODULE__, arg, [name: :bob])
  end

  def init(arg) do
    IO.inspect {:starting, arg}
    {:ok, []}
  end
end

```
In `iex -S mix`

```
{:ok, pid} = Restarter.start_link({MyGenServer, :start_link, [:sue]}, 10000, [name: :restarter])
Process.whereis(:bob) # It's been started

Process.whereis(:bob) |> Process.exit(:kill)

Process.whereis(:bob) # nil

# Wait 10 seconds


Process.whereis(:bob) # It's been re-started

```

Obviously, you would be starting all this in a supervision tree, with the `Restarter` as a `worker`.
