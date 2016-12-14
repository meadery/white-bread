defmodule WhiteBread.Outputers.HTML.Formatter do
  @moduledoc "HTML formatter"

  def document(content) when is_binary(content) do
    "<!DOCTYPE html><html>#{content}</html>"
  end

  def body(content) when is_binary(content) do
    "<body>#{content}</body>"
  end

  def list([]) do
    "Nothing to report."
  end

  def list(elements) when is_list(elements) and length(elements) > 0 do
    list(elements, "")
  end

  defp list([], content) do
    "<ul style=\"list-style-type:square\">#{content}</ul>"
  end

  defp list([ head | tail ], content) when is_binary(head) do
    list(tail, content <> element(head))
  end

  defp element(content) when is_binary(content) do
    "<li>#{content}</li>"
  end

  def success(text) when is_binary(text), do: text

  def failure(text) when is_binary(text), do: "<font color=\"red\">FAILURE:</font> #{text}"
end
