Simple [Lambda Calculus](https://en.wikipedia.org/wiki/Lambda_calculus) interpreter written in Haskell.

## Quick Start

```bash
# Run the REPL
cabal run
# Run the REPL without std
cabal run exes -- --no-std
```

## REPL Commands

```text
================================================================================
# Commands:                                                                    #
#                                                                              #
#     :help                   show commands                                    #
#     :quit                   exit repl                                        #
#     :info <name>            show information about <name>                    #
#     :save <path>            save bindings to <path>                          #
#     :load [<path>]          load source file(s)                              #
================================================================================
```

## Syntax

### Variables

Variable names must start with a letter and can be followed by alphanumeric characters.

```
λ> var123
var123
λ> 123
<!> Invalid name (missing initial letter).
λ> 
```

(this error message is not implement yet)

### Functions

Functions must start with either a lambda `λ` or a more convenient backslash `\`.\
The parameter and body are separated with a dot `.`.

```
λ> \x.x
λx.x
λ> λ x . x
λx.x
λ> 
```

The interpreter also supports multiple parameters, to do this, have the parameters separated by a space before the dot `.`.

```
λ> \a b.a
λa b.a
λ> \a.\b.a
λa b.a
λ> 
```

### Applications

Applications are represented by two expressions separated with a space.\
If the first expression is a lambda, you must wrap it in parentheses, otherwise, the second expression is interpreted as part of its body.


```
λ> f x
f x
λ> (\x.x) a
a
λ> 
```

Applications are left-associative.

```
λ> ((f g) h) x
f g h x
λ> f (g (h x)))
f (g (h x)))
λ> 
```

### Bindings

An expression can be assigned to a name using the assignment operator `:=` or a more convenient equality operator `=`.

```
λ> id := \x.x
λ> id a
a
λ> 
```

A binding can be updated.

```
λ> id := \x.x
λ> id := f
λ> id a
f a
λ> 
```

To check the expression assigned to a name, you can use the command `:info`.

```
λ> :info id
λx.x
λ> :info foo
<!> "foo" is not defined.
λ> 
```

### Recursion

Because of Haskell's [lazy evaluation](https://en.wikipedia.org/wiki/Lazy_evaluation), an expression assigned to a name is not evaluated until the name is used.\
This means you can't do recursion by simply using the name you're defining in its expression.

```
λ> foo := foo
λ> foo
foo
λ> 
```

The solution is the [Y combinator](https://en.wikipedia.org/wiki/Fixed-point_combinator#Y_combinator_in_lambda_calculus).

```
λ> Y = \f.(\x.f (x x)) (\x.f (x x))
λ> Y a
a (a (a (a ...
λ> 
```
