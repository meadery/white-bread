defmodule WhiteBread.Outputers.HTML.FormatterTests do
	use ExUnit.Case
  alias WhiteBread.Outputers.HTML.Formatter

  test "building a document" do
    assert "<!DOCTYPE html><html>Hello world.</html>" == Formatter.document "Hello world."
  end

  test "building a list" do
    assert "<ul style=\"list-style-type:square\"><li>fu</li></ul>" == Formatter.list ["fu"]
  end

  test "success and failure elements" do
    assert "<font color=\"red\">FAILURE:</font> fu" == Formatter.failure "fu"
  end
end
