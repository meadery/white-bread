WhiteBread
==========
[![Build Status](https://travis-ci.org/meadsteve/white-bread.svg?branch=master)](https://travis-ci.org/meadsteve/white-bread)
[![Stories in Ready](https://badge.waffle.io/meadsteve/white-bread.png?label=ready&title=Ready)](https://waffle.io/meadsteve/white-bread)
[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/meadsteve/white-bread?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

# Looking for maintainers
This project is looking for people who'd like to volunteer to be an admin/maintainer: Discuss here: https://github.com/meadsteve/white-bread/issues/88

# What?
Story BDD tool written in and for Elixir. Based on [cucumber](https://cukes.info/).
Parses Gherkin formatted feature files and executes them as acceptance tests.

## Is this a testing tool?
The short answer is no. The medium answer is it's a development tool that should really be used in conjuction with some testing framework. For a longer answer checkout this post by Aslak Hellesøy: [the world's most misunderstood collaboration tool](https://cukes.info/blog/2014/03/03/the-worlds-most-misunderstood-collaboration-tool).

## Why the name?
Gherkin and cucumber made me think of [cucumber sandwiches](http://en.wikipedia.org/wiki/Cucumber_sandwich).
Which are traditionally made with very thin white bread.

# Alternative tools
Before adopting whitebread you should investigate the alternaitves. This project (whitebread) contains a lot of code around setup, execution, and output of tests. An alternative gherkin based BDD tool can be found at https://github.com/cabbage-ex/cabbage. Cabbage parses gherkin feature files and creates exunit tests. This means a lot more of the logic is standard exunit code.

# Getting started - installing
Add "white_bread" to your `mix.exs` file with the version you wish to use:

```elixir
defp deps do
    [
        ...
        { :white_bread, "~> 4.1.1", only: [:dev, :test] }
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
This should prompt you with a few messages like:

```bash
loading config from features/config.exs
Config file not found at features/config.exs.
Create one [Y/n]?
y

Suite: All
Context module not found Elixir.WhiteBreadContext (features/contexts/white_bread_context.exs)
Create one [Y/n]?
y

```
This will create a basic config file and also a context ```features/contexts/white_bread_context.exs```.
A context file tells WhiteBread how to understand the gherkin in your feature files and also
what setup is required.

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

  # `_status` will be either {:ok, scenario} | {:error, reason, scenario}
  scenario_finalize fn _status, state ->
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

If you want to run WhiteBread in test environment run this
```
MIX_ENV=test mix white_bread.run
```

To execute on each time WhiteBread in test environment without prefixing the command with `MIX_ENV=test`, you can also add this line in `mix.exs`

```
def project do
    [
        ...
        preferred_cli_env: ["white_bread.run": :test],
        ...
    ]
end
```

## Integrating a testing library

By default, `use WhiteBread.Context` will import ExUnit.Assertions. If you're not using ExUnit, you'll probably want to override this default by calling `use WhiteBread.Context, test_library: :some_other_library_name`.

At the moment, the only library names available are `:ex_unit` (same as the default), `:espec`, and `nil` (which skips the test library setup step altogether).

# Next steps - Additional Suites and subcontexts

After following the getting started steps you may find your default context starts to get a bit large.
There are two ways this can be broken apart:

1. By composing your default suite out of subcontexts using the `import_steps_from` macro.
2. By splitting your features into different suites each starting with a different context.

## Subcontexts

Sub contexts allow the step definitions of multiple contexts to be imported in to a parent context.
The parent context defines all the start and stop callbacks but all the steps in the child context
will be available.

```elixir
defmodule WhiteBread.Example.DefaultContext do
  use WhiteBread.Context

  import_steps_from WhiteBread.Example.SharedContext

  # Rest of the context here as usual
  #...
end
```

## Multiple suites

Defining suites allows you to use a different starting context for groups of features. This will
often be along the lines of a bounded context.
You can also run one feature multiple times under different contexts. This is especially useful
if you have a few different ways of accessing your software (web, rest api, command line etc.).

Suite configuration is loaded from ```features/config.exs```. An example with multiple suites is:

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
Each suite gets run loading all the features in the given paths and running them using the specified context.
Additionally the scenarios can be filtered to specific tags.

## Suites: Context per feature

This is part of the Suite Configuration and it automatically maps a `.feature` with a `context` module file automatically.

It is also possible to run this with additional manually defined suites.

Example:
```elixir
defmodule WhiteBread.Example.Config do
  use WhiteBread.SuiteConfiguration

  context_per_feature namespace_prefix: WhiteBread.Example,
                      entry_path: "features/context_per_feature"

  # Extra config can also be provided to apply to each generated suite                      
  context_per_feature namespace_prefix: WhiteBread.Example,
                      entry_path: "features/context_per_feature",
                      extra: [
                        tags: ['special']
                      ]

  suite name:          "Alternate",
        context:       WhiteBread.Example.AlternateContext,
        feature_paths: ["features/sub_dir_two"]
end
```

About the `context_per_feature` configuration:

- `namespace_prefix:` the namespace your modules will start with. The file name of the feature will be converted into a module name and appended to the end of the `namespace_prefix` e.g. `my_new_sandwich.feature` to `WhiteBread.Example.MyNewSandwichContext`
- `entry_path:` the location of your feature files.

**note:** context files need to be added to your `features/contexts` folder still.

## Speeding things up - async running

More than likely you have a multicore machine. To get things going a little
faster each suite can be configured to run all features and scenarios in a
separate process.

This can be done by setting run_async to true on any suite:
```elixir
defmodule WhiteBread.Example.Config do
  use WhiteBread.SuiteConfiguration

  suite name:          "Speedy run",
        context:       WhiteBread.Example.DefaultContext,
        feature_paths: ["features/sub_dir_one"],
        run_async:     true
end
```
note: At the moment each suite will be run sequentially in the order they appear
in the config file.

## Speeding things up - timeouts
By default each scenario gets 30 seconds to execute. After which point it will
fail with a timeout warning. Each context can define a custom timeout function:

```elixir
defmodule WhiteBread.Example.DefaultContext do
  use WhiteBread.Context
  scenario_timeouts fn _feature, scenario ->
    case scenario.name do
      "possible slow scenario" -> 60_000
      _               -> 5000
    end
  end

  # Rest of the context here as usual
  #...
end
```
This function gets the full structs representing the feature and scenario being
executed so it's possible to base the decision to change the timeout on any
available property: tags, name, description etc.

## HTML Output (and other outputs)

For HTML reports configure WhiteBread (e.g. in `config.exs`) with the HTML outputer and optionally a file name for the document:

JSON reports are also available.

```Elixir
config :white_bread,
  outputers: [{WhiteBread.Outputers.Console, []},
              {WhiteBread.Outputers.HTML, path: "~/build/whitebread_report.html"},
              {WhiteBread.Outputers.JSON, path: "~/build/whitebread_report.json"}
             ]
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
* The messages that custom outputers receive (documented in WhiteBread.Outputer)

Any changes outside of the above will not be considered a BC break. Although every effort will be made to not introduce unnecessary change in any other area.

# Contribute
Contributions more than welcome but please raise an issue first to discuss any large changes.
