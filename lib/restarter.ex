defmodule Restarter do
  @moduledoc """
  Acts as a back stop. Starts a service (with the supplied module, function, and args).
  The function is expected to return {:ok, pid}.

  Should the service exit, then it is restarted after an interval. There is also the opportunity
  to delay the start by a period of time.
  """
  use GenServer

  @doc """
  Start this `Restarter`, and also start the child. Arguments:
  * `{module, function, arg}` - the child function to start. The function should return `{:ok, pid}`.
  * `retry_interval` - on destruction of the child, the number of milliseconds to wait before restarting
  * `restarter_otp_opts` - OTP options for this Genserver, such as the name. Defaults to  `[]`
  * `start_delay` - the number of milliseconds to wait before first starting the child. Defaults to `0`.
  """
  def start_link({module, function, args}, retry_interval, restarter_otp_opts \\ [], start_delay \\ 0) do
    GenServer.start_link(__MODULE__,
                         {%{retry_interval: retry_interval,
                           module: module,
                           function: function,
                           args: args}, start_delay},
                         restarter_otp_opts)
  end

  def init({status, start_delay}) do
    Process.send_after(self(), :start, start_delay)
    Process.flag(:trap_exit, true)
    {:ok, status}
  end

  def handle_info(:start, state = %{module: module, function: function, args: args, retry_interval: retry_interval}) do
    case apply(module, function, args) do
      {:ok, pid} -> Process.link(pid)
      _ -> Process.send_after(self(), :start, retry_interval)
    end
    {:noreply, state}
  end

  def handle_info({:EXIT, _pid, _reason}, status = %{retry_interval: retry_interval}) do
    Process.send_after(self(), :start, retry_interval)
    {:noreply, status}
  end
end
