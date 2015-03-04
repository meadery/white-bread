WhiteBread
==========
[![Build Status](https://travis-ci.org/meadsteve/white-bread.svg?branch=master)](https://travis-ci.org/meadsteve/white-bread)

# What?
Very alpha Story BDD tool written in and for Elixir.
Parses Gherkin formatted feature files and executes them as tests.
Initially started as an experiment. The API will change heavily.

# Basic usage
Create *.feature files in a features directory. They should be gherkin syntax like:
```gherkin
Feature: Serve coffee
  Coffee should not be served until paid for
  Coffee should not be served until the button has been pressed
  If there is no coffee left then money should be refunded

  Scenario: Buy last coffee
  Given there are 1 coffees left in the machine
  And I have deposited £1
  When I press the coffee button
  Then I should be served a coffee
```

Create a context module. This matches each of the steps in a scenario.
```elixir
defmodule SunDoe.CoffeeShopContext do
  use WhiteBread.Context

  given_ "there are 1 coffees left in the machine", fn _state ->
    {:ok, HashDict.new |> Dict.put(:coffees, 1)}
  end

  given_ ~r/I have deposited £(?<pounds>[0-9]+)/, fn state, pounds: pounds ->
    {:ok, state |> Dict.put(:pounds, pounds)}
  end

  when_ "I press the coffee button", fn state ->
    # Domain logic to serve coffees would happen
    # here. Then update the state with the result
    {:ok, state |> Dict.put(:coffees_served, 1)}
  end

  then_ "I should be served a coffee", fn state ->
    served_coffees = state |> Dict.get(:coffees_served)
    assert served_coffees == 1
    {:ok, :whatever}
  end
end
```
Then run:

```mix white_bread.run SunDoe.CoffeeShopContext ```


# Contribute ?
Contributions more than welcome but please raise an issue first to discuss any large changes.
