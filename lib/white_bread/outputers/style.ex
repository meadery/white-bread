defmodule WhiteBread.Outputers.Style do
	
	def success(message) do
		color(:green, message)
	end

	def failed(message) do
		color(:red, message)
	end

	def color(color, string_msg) do
    [IO.ANSI.format_fragment([color], IO.ANSI.enabled?), 
    string_msg, 
    IO.ANSI.format_fragment(:reset, IO.ANSI.enabled?)] 
    |> IO.iodata_to_binary
  end
end