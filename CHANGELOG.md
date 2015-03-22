# Changelog

## v0.5.0 (2015-03-22)

### Enhancements
* Added stack trace to function clause match errors

### Bug fixes
no significant fixes

### Backwards incompatible changes
* error returned for :no_clause_match is now a tuple like {FunctionMatchError, Trace}

## v0.4.0 (2015-03-21)

### Enhancements
* Added table handling. Any step followed by a table will get key :table_data
* Added support for scenario outlines
* Add code suggestions for missing steps
* All step functions can now be arity 1 or 2

### Bug fixes
no significant fixes

### Backwards incompatible changes
* step functions now only have 1 or 2 arguments. The second argument is always a map. Previously regex named matches each became an argument.

## v0.3.0 (2015-03-14)

### Enhancements
* Added initial_state macro which takes a block that returns the starting state
for a context.

### Bug fixes
no significant fixes

### Backwards incompatible changes
none


## v0.2.0 (2015-03-09)

### Enhancements
* Added support for --tags on mix task.
* Added default Context loaded from features/default_contect.exs

### Bug fixes
* warnings for a handful of unused variables removed.

### Backwards incompatible changes
none
