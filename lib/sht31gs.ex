defmodule Sht31gs do
  @moduledoc """
  Documentation for Sht31gs.
  """

  import ElixirALE
  alias ElixirALE.I2C

  use GenServer
  require Logger

  defstruct [i2c_pid: nil, i2c: %{addr: nil, reg: <<0x2c, 0x06>>} ]


  @doc """
  """

  def start_link(addr) do
    start(addr)
  end

  def start(addr) do
     GenServer.start_link(__MODULE__, [addr: addr ], [name: :sht31gs, timeout: 5000])
  end

  def read() do
    GenServer.call(:sht31gs, :read_device)
    |> format_data
  end

  def stop() do
    GenServer.cast(:sht31gs, {:close_device})
  end

  def init([addr: addr]) do

    Logger.info("initializing Sht31 GenServer with device address: #{inspect addr}")
 
    state = %Sht31gs{}
    i2c = Map.put(state.i2c, :addr, addr)
    state = Map.put(state, :i2c, i2c)

    case  I2C.start_link("i2c-1", addr) do
      {:ok, pid} ->
        state = Map.put(state, :i2c_pid, pid)
	IO.puts("init state: #{inspect state}")
	{:ok, state}
      fail ->
    	Logger.info("failed to open i2c device: #{inspect fail}")
	{:stop, :failed_to_start_i2c}
    end
  end

  def handle_call(:read_device, {_from, _ref}, state) do
    %Sht31gs{i2c_pid: pid, i2c: %{addr: _addr, reg: reg}} = state
    I2C.write(pid, reg)
    :timer.sleep(500)
  
    # SHT31 address, 0x44(68)
    # Read data back from 0x00(00), 6 bytes
    # Temp MSB, Temp LSB, Temp CRC, Humididty MSB, Humidity LSB, Humidity CRC
    {:reply, read_sensor(pid, 5), state}
  end

  def handle_cast({:close_device}, %Sht31gs{i2c_pid: pid, i2c: %{reg: _reg}} = state) do
    Logger.info("terminating Sht31gs GenServer and releasing i2c GenServer")
    I2C.release(pid)
    {:stop, :terminated, state}
  end

  defp read_sensor(_pid, 0) do
	 :failed_to_read
  end

  defp read_sensor(pid, retry) do
    case I2C.read(pid, 6) do
      {:error, :i2c_read_failed} ->
        :timer.sleep(500)
	read_sensor(pid, retry - 1)
      <<d0::8,d1::8,d2::8,d3::8,d4::8,d5::8>> ->
          <<d0::8,d1::8,d2::8,d3::8,d4::8,d5::8>>
    end
  end
 
  defp format_data(:failed_to_read), do: IO.puts "failed to read sensor"
  defp format_data(<<d0::8,d1::8,_d2::8,d3::8,d4::8,_d5::8>>) do
    # Convert the data
    temp = d0 * 256 + d1
    cTemp = -45 + (175 * temp / 65535.0)
    fTemp = -49 + (315 * temp / 65535.0)
    humidity = 100 * (d3 * 256 + d4) / 65535.0
 
    # Output data to screen
   IO.puts "Temperature in Celsius is : #{inspect round(cTemp * 100) / 100}"
   IO.puts "Temperature in Fahrenheit is :#{inspect round(fTemp * 100) / 100}"
   IO.puts "Relative Humidity is : #{inspect round(humidity * 100) / 100}" <> "%"
  end
end
