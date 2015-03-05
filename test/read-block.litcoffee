# Test for read_block

I just wanted to make sure I could read from stdin in the same way the bash `read` command does. To run this test, you have to pipe some data via the command line and check the output. It should write the third line from stdin to stdout.

## Example

```sh
ls | coffee --nodejs --harmony ./test/read-block.litcoffee
README.md
```

## Test Code

Our strategy here is to:

* Transform `stdin` into a line stream (returning a line at a time, where each line is separated via a newline)

* Generate a function to read each line with `read_block` (which returns a function, not the block)

* Call that resulting function three times, using `times`, and destructuring the results into `rest` and `third`

* `yield` to `third` (since the read function generated by `read_block` returns a promise for the block, or, in this case, a line, not the block/line itself)

> 

    {read_block, lines, times} = require "../src/index"
    {call} = require "when/generator"
    call ->
      [rest..., third] = times (read_block lines process.stdin), 3
      console.log yield third