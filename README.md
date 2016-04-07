WhiteBread
==========
[![Build Status](https://travis-ci.org/meadsteve/white-bread.svg?branch=master)](https://travis-ci.org/meadsteve/white-bread)
[![Hex Version](http://img.shields.io/hexpm/v/white_bread.svg?style=flat)](https://hex.pm/packages/white_bread)
[![Stories in Ready](https://badge.waffle.io/meadsteve/white-bread.png?label=ready&title=Ready)](https://waffle.io/meadsteve/white-bread)
[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/meadsteve/white-bread?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

# What?
Story BDD tool written in and for Elixir. Based on [cucumber](https://cukes.info/).
Parses Gherkin formatted feature files and executes them as acceptance tests.

## Is this a testing tool?
The short answer is no. The medium answer is it's a development tool that should really be used in conjuction with some testing framework. For a longer answer checkout this post by Aslak Hellesøy: [the world's most misunderstood collaboration tool](https://cukes.info/blog/2014/03/03/the-worlds-most-misunderstood-collaboration-tool).

## Why the name?
Gherkin and cucumber made me think of [cucumber sandwiches](http://en.wikipedia.org/wiki/Cucumber_sandwich).
Which are traditionally made with very thin white bread.

# Getting started - installing
Add "white_bread" to your `mix.exs` file with the version you wish to use:

```elixir
defp deps do
    [
        ...
        { :white_bread, "~> 2.5", only: [:dev, :test] }
        ...
    ]
end
```

# Getting started - Basic usage
Create a features directory. In here add some *.feature files describing your software. They should be gherkin syntax like:

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
Run the command:
```bash
mix white_bread.run
```
This will prompt you with a message like:
```
Default context module not found in features/contexts/default_context.exs.
Create one [Y/n]?
```
Selecting yes will create a basic context file in ```features/contexts/default_context.exs```.
The context file tells WhiteBread how to understand the gherkin in your feature files.
These will need to be implemented like:

```elixir
defmodule SunDoe.CoffeeShopContext do
  use WhiteBread.Context

  feature_starting_state fn  ->
    coffee_storage = setup_coffee_storage
    %{in_memory_coffee_db: coffee_storage}
  end

  scenario_starting_state fn state ->
    state.in_memory_coffee_db |> clear_db
    state
  end

  scenario_finalize fn state ->
    state.in_memory_coffee_db |> shutdown_db
  end

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

    # The context automatically imports ExUnit.Assertions
    # so any usual assertions can be made
    assert served_coffees == 1

    {:ok, :whatever}
  end
end
```

After doing this rerun

```
mix white_bread.run
```

# Next steps - Suites and subcontexts

After following the getting started steps you may find your default context starts to get a bit large. Defining suites allows you to break your your contexts apart and assign them to specific features. You can even run one feature multiple times under different contexts. This is especially useful if you have a few different ways of accessing your software (web, rest api, command line etc.).

Suite configuration is loaded from ```features/config.exs```. Create this file then add something like:

```elixir
defmodule WhiteBread.Example.Config do
  use WhiteBread.SuiteConfiguration

  suite name:          "Default",
        context:       WhiteBread.Example.DefaultContext,
        feature_paths: ["features/sub_dir_one"]

  suite name:          "Alternate",
        context:       WhiteBread.Example.AlternateContext,
        feature_paths: ["features/sub_dir_two"]

  suite name:          "Alternate - Songs",
        context:       WhiteBread.Example.AlternateContext,
        feature_paths: ["features/sub_dir_one"],
        tags:          ["songs"]
end
```
Each suite gets run loading all the features in the given paths and running them using the specified context. Additionally the scenarios can be filtered to specific tags.

## Suites: Context per feature

This is part of the Suite Configuration and it automatically maps a `.feature` with a `context` module file automatically.

It is also possible to run this with additional manually defined suites.

Example:
```elixir
defmodule WhiteBread.Example.Config do
  use WhiteBread.SuiteConfiguration

  context_per_feature namespace_prefix: WhiteBread.Example,
                      entry_path: "features/context_per_feature"

  suite name:          "Alternate",
        context:       WhiteBread.Example.AlternateContext,
        feature_paths: ["features/sub_dir_two"]
end
```

About the `context_per_feature` configuration:

- `namespace_prefix:` the namespace your modules will start with. The file name of the feature will be converted into a module name and appended to the end of the `namespace_prefix` e.g. `my_new_sandwich.feature` to `WhiteBread.Example.MyNewSandwichContext`
- `entry_path:` the location of your feature files.

**note:** context files need to be added to your `features/contexts` folder still.

## Subcontexts

It's quite likely that there will be some common steps in your contexts. These steps can be stored in a shared context then imported as a subcontext:
```elixir
defmodule WhiteBread.Example.DefaultContext do
  use WhiteBread.Context

  subcontext WhiteBread.Example.SharedContext

  # Rest of the context here as usual
  #...
end
```

# Public interface and BC breaks
The public interface of this library covers:

* The exported mix command: ```mix white_bread.run```
* The ```WhiteBread``` and ```WhiteBread.Helpers``` modules.
* The macros exported by the ```WhiteBread.Context``` module.
* The ContextBehaviour defined in ```WhiteBread.ContextBehaviour```.
* The config.exs structure and the macros exported by the ```WhiteBread.SuiteConfiguration``` module.
* The structures defined in ```WhiteBread.Gherkin```.
* The location of feature and context files loaded automatically.

Any changes outside of the above will not be considered a BC break. Although every effort will be made to not introduce unnecessary change in any other area.

# Contribute
Contributions more than welcome but please raise an issue first to discuss any large changes.
