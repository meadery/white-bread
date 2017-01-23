defmodule WhiteBread.Outputers.HTML.Formatter do
  @moduledoc "HTML formatter"

  def document(content) when is_binary(content) do
    "<!DOCTYPE html><html>#{content}</html>"
  end

  def body(content) when is_binary(content) do
    "<body>#{head "White Bread Results"}#{content}</body>"
  end

  defp head(content) do
    "<h1>#{content}</h1>"
  end

  def section(_, []) do
    ""
  end
  def section(title, results) when is_binary(title) do
    "#{paragraph("Suite: " <> bold(title))}#{list(results)}"
  end

  def list([]), do: "Nothing to report."
  def list([_|_] = elements), do: list(elements, "")

  defp list([], content) do
    "<ul style=\"list-style-type:square\">#{content}</ul>"
  end
  defp list([head|tail], content) when is_binary(head) do
    list(tail, content <> element(head))
  end

  defp element(content) when is_binary(content) do
    "<li>#{content}</li>"
  end

  defp paragraph(content) when is_binary(content) do
    "<p>#{content}</p>"
  end

  defp bold(x) do
      "<b>#{x}</b>"
  end

  def success(text) when is_binary(text) do
    test(text, "green", "OK")
  end

  def failure(text) when is_binary(text) do
    test(text, "red", "FAILURE")
  end

  defp test(text, color, indicator) do
    "<font color=\"#{color}\">#{indicator}:</font> #{text}"
  end
end
