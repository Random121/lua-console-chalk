# lua-console-chalk

It is like the [chalk for javascript](https://github.com/chalk/chalk) except made in lua. Note that this only work with outputs which support [ANSI escape sequences](https://en.wikipedia.org/wiki/ANSI_escape_code).

## Similarities to Chalk for javascript

Lua chalk support all modifiers and basic colors from javascript chalk with the exception of `visible` and `overline`.

Modifiers `inverse`, `hidden`, and `strikethrough` are renamed to `invert`, `hide`, and `strike` respectively to better match ANSI documentation.

Lua chalk does not have support for 256 colors and Truecolor.

## Compatibility

Although lua chalk offers support for most ANSI modifiers, some such as `italic`, `hide`, and `strike` are not widely supported.