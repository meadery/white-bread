defmodule WhiteBread.Outputers.Style do

  @style_atoms [{:failed, :red}, {:ok, :green},
  {:exception, :yellow}, {:info, :blue}]

  def decide_color(style, message) when is_atom(style) do
    if(Keyword.has_key? @style_atoms, style) do
      color(@style_atoms[style], message)
    else
      message
    end
  end

  def success(message) do
    color(@style_atoms[:ok], message)
  end

  def failed(message) do
    color(@style_atoms[:failed], message)
  end

  def exception(message) do
    color(@style_atoms[:exception], message)
  end

  def info(message) do
    color(@style_atoms[:info], message)
  end

  def color(color, string_msg) do
    [IO.ANSI.format_fragment([color], IO.ANSI.enabled?),
    string_msg,
    IO.ANSI.format_fragment(:reset, IO.ANSI.enabled?)]
    |> IO.iodata_to_binary
  end
end
