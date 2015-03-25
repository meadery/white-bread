WhiteBread
==========
[![Build Status](https://travis-ci.org/meadsteve/white-bread.svg?branch=master)](https://travis-ci.org/meadsteve/white-bread)
[![Hex Version](http://img.shields.io/hexpm/v/white_bread.svg?style=flat)](https://hex.pm/packages/white_bread)

# What?
Story BDD tool written in and for Elixir. Based on [cucumber](https://cukes.info/).
Parses Gherkin formatted feature files and executes them as acceptance tests.

## Is this a testing tool?
The short answer is no. The medium answer is it's a development tool that should really be used in conjuction with some testing framework. For a longer answer checkout this post by Aslak Hellesøy: [the world's most misunderstood collaboration tool](https://cukes.info/blog/2014/03/03/the-worlds-most-misunderstood-collaboration-tool).

## Why the name?
Gherkin and cucumber made me think of [cucumber sandwiches](http://en.wikipedia.org/wiki/Cucumber_sandwich).
Which are traditionally made with very thin white bread.

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

Create ```features/default_context.exs``` and create a module using ```WhiteBread.Context```
This matches each of the steps in a scenario to some code.

```elixir
defmodule SunDoe.CoffeeShopContext do
  use WhiteBread.Context

  given_ "there are 1 coffees left in the machine", fn state ->
    {:ok, state |> Dict.put(:coffees, 1)}
  end

  given_ ~r/^I have deposited £(?<pounds>[0-9]+)$/, fn state, %{pounds: pounds} ->
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

```mix white_bread.run```

# Gherkin Syntax covered
- [x] Features
- [x] Step definitions: '''given''', '''when''', '''then''', '''and''' and '''but'''
- [x] Feature backgound steps
- [x] Scenerios
- [x] Scenario outlines
- [x] Tags

# Public interface and BC breaks
The public interface of this library covers:

* The exported mix command: ```mix white_bread.run```
* The ```WhiteBread``` and ```WhiteBread.Helpers``` modules.
* The macros exported by the ```WhiteBread.Context``` module.
* The structures defined in ```WhiteBread.Gherkin```.

Any changes outside of this will not be considered a BC break.

# Contribute
Contributions more than welcome but please raise an issue first to discuss any large changes.
