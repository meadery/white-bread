defmodule WhiteBread.Outputers.StyleTests do
	use ExUnit.Case
	alias WhiteBread.Outputers.Style, as: Style

	test "check failed message is in `red` colour encoding" do
		styled_binary = Style.failed("Exception was thrown")
		assert styled_binary == "\e[31mException was thrown\e[0m"
	end

	test "check success message is in `green` colour encoding" do
		styled_binary = Style.success("Success message")
		assert styled_binary == "\e[32mSuccess message\e[0m"
	end

	test "decide how to colour a failed message with red" do
		styled_binary = Style.decide_color(:failed, "Exception was thrown");
		assert String.contains? styled_binary, "\e[31m"
	end

	test "no colour style atom then return plain message" do
		styled_binary = Style.decide_color(:no_color, "I'm just a message");
		assert styled_binary == "I'm just a message"
	end

end