# gleam_md

[![Package Version](https://img.shields.io/hexpm/v/gleam_md)](https://hex.pm/packages/gleam_md)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/gleam_md/)

```sh
gleam add gleam_md
```
```gleam
import gleam_md

pub fn main() {
  "
# Header 1 goes here
sub title
## Header 2

header 1
========

header 2
--------

*Italic*, _italic_ and **bold**.

[Markdown Guide](https://www.markdownguide.org/)

![Markdown Logo](https://markdown-here.com/img/icon256.png)

---

> Blockquote

* List item 1
* List item 2

> This is an important
> quote
> to match multi line
>> also a nested quote

Paragraph

1. Ordered list 1
1. Ordered list 2
    - Inner 1
    - Inner 2
" |> gleam_md.render
}
```

Further documentation can be found at <https://hexdocs.pm/gleam_md>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```
