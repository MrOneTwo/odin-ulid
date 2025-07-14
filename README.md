[ULID](https://github.com/ulid/spec) implementation in [Odin](https://odin-lang.org/).

ULID is stored as a `u128`, which is offered by [Odin as a basic type](https://odin-lang.org/docs/overview/#basic-types). Nice!
Life would be great if we could stay in the world of `u128` the entire
time. We need to represent the ULID as a [Crockford base 32](http://www.crockford.com/base32.html)
encoded string, which then puts us in the world of memory management,
because one has to decide where to store those strings.
