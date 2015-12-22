defmodule WhiteBread.Outputers.StyleTests do
	use ExUnit.Case
	alias WhiteBread.Outputers.Style, as: Style

	test "check failed message is in `red` colour encoding" do
		styled_binary = Style.failed("Exception was thrown")
		assert String.contains? styled_binary, "\e[31m"
		assert String.contains? styled_binary, "Exception"
	end

	test "check success message is in `green` colour encoding" do
		styled_binary = Style.success("Success message")
		assert String.contains? styled_binary, "\e[32m"
		assert String.contains? styled_binary, "Success"
	end

end