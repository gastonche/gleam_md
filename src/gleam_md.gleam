import gleam/io
import gleam/regex.{type Match}
import gleam/list
import gleam/string
import gleam/int
import gleam/option.{None, Some}
import gleam/result
import gleam/dict.{type Dict}

const regex_options = regex.Options(case_insensitive: True, multi_line: True)

pub type Options {
  Options(class_names: Dict(String, String))
}

pub fn render(markdown: String) {
  render_with_optioins(markdown, Options(class_names: dict.from_list([])))
}

pub fn render_with_optioins(markdown: String, options: Options) {
  markdown
  |> string.trim
  |> parse_headers(options)
  |> parse_horizontal_rule(options)
  |> parse_emphasis(options)
  |> parse_images(options)
  |> parse_links(options)
  |> parse_block_quotes(options)
  |> parse_lists(options)
  |> parse_paragraphs(options)
}

fn to_regex(r: String, options, default: a, next: fn(regex.Regex) -> a) {
  case regex.compile(r, options) {
    Ok(exp) -> next(exp)
    Error(e) -> {
      io.println_error(e.error)
      default
    }
  }
}

fn replace_all(
  text: String,
  r: String,
  get_replacement: fn(List(regex.Match)) -> String,
) {
  use exp <- to_regex(r, regex_options, text)
  regex.scan(exp, text)
  |> get_replacement
}

fn replace(text: String, r: String, get_replacement: fn(List(String)) -> String) {
  replace_all(text, r, list.fold(
    _,
    text,
    fn(acc, match: regex.Match) {
      string.replace(
        acc,
        match.content,
        get_replacement(list.map(match.submatches, option.unwrap(_, ""))),
      )
    },
  ))
}

fn get_classnames(options: Options, tags: List(String)) {
  let classes =
    list.fold(tags, "", fn(acc, tag) {
      acc <> " " <> result.unwrap(dict.get(options.class_names, tag), "")
    })
    |> string.trim

  " class=\"" <> classes <> "\""
}

fn form_element(
  tag tag: String,
  content content: String,
  options options: Options,
) {
  "<"
  <> tag
  <> get_classnames(options, [tag])
  <> ">"
  <> content
  <> "</"
  <> tag
  <> ">"
}

fn form_element_with_attrs(
  tag tag: String,
  attrs attrs: String,
  content content: String,
  options options: Options,
) {
  "<"
  <> tag
  <> get_classnames(options, [tag])
  <> attrs
  <> ">"
  <> content
  <> "</"
  <> tag
  <> ">"
}

fn get_at(
  words words: List(a),
  at at: Int,
  default default: b,
  next next: fn(a) -> b,
) {
  case list.at(words, at) {
    Ok(first) -> next(first)
    Error(_) -> default
  }
}

fn parse_headers(text: String, options: Options) {
  text
  |> replace("^(#{1,6})\\s(.+)$|^([^\\n]+)\\n(=+|-+)$", fn(matches) {
    let #(count, content) = case matches {
      [first, content] -> {
        let count =
          first
          |> string.length
          |> int.to_string
        #(count, content)
      }
      ["", "", content, selector] -> {
        let count = case string.contains(selector, "=") {
          True -> "1"
          False -> "2"
        }
        #(count, content)
      }
      _ -> #("6", "")
    }
    let tag = "h" <> count
    form_element(tag, content, options)
  })
}

// TODO: update to support nested em and strong patterns
fn parse_emphasis(text: String, options: Options) {
  text
  |> replace("\\*\\*(.+?)\\*\\*", fn(matches) {
    list.fold(matches, "", fn(acc, match) {
      acc <> form_element("strong", match, options)
    })
  })
  |> replace("(?:\\*|_)(.+?)(?:\\*|_)", fn(matches) {
    list.fold(matches, "", fn(acc, match) {
      acc <> form_element("em", match, options)
    })
  })
}

fn parse_links(text: String, options: Options) {
  text
  |> replace("\\[(.+?)\\]\\((.+?)\\)", fn(matches) {
    use word <- get_at(matches, 0, text)
    use link <- get_at(matches, 1, text)
    form_element_with_attrs("a", " href=\"" <> link <> "\"", word, options)
  })
}

fn parse_images(text: String, options: Options) {
  text
  |> replace("!\\[(.*?)\\]\\((.*?)\\)", fn(matches) {
    use word <- get_at(matches, 0, text)
    use link <- get_at(matches, 1, text)
    "<img"
    <> get_classnames(options, ["img"])
    <> " src=\""
    <> link
    <> "\""
    <> " alt=\""
    <> word
    <> "\""
    <> " />"
  })
}

fn parse_horizontal_rule(text: String, options: Options) {
  text
  |> replace("^([*_-])\\1{2,}$", fn(_) {
    "<hr" <> get_classnames(options, ["hr"]) <> " />"
  })
}

fn parse_block_quotes(text: String, options: Options) {
  use matches <- replace(text, "^>((?:.*(?:\n(?=>)|(?!\n{2,}).*))+)")
  use acc, match <- list.fold(matches, "")
  let match = replace(match, "^> ", fn(_m) { "" })
  acc
  <> form_element(
    "blockqoute",
    "\n" <> parse_block_quotes(string.trim(match), options) <> "\n",
    options,
  )
}

fn parse_list_item(match: Match, options: Options) {
  case match.submatches {
    [_, Some(_), Some(content), None] -> form_element("li", content, options)
    [_, Some(_), Some(content), Some(sublist)] ->
      form_element(
        "li",
        content <> render_with_optioins(unindent(sublist), options),
        options,
      )
    _ -> ""
  }
}

fn unindent(text: String) {
  text
  |> string.trim
  |> string.split("\n")
  |> list.fold("", fn(acc, line) { acc <> string.trim(line) <> "\n" })
}

fn parse_list(text: String, options: Options) {
  let parse = fn() {
    use matches <- replace_all(
      text,
      // match all list items along with their sub lists
      "^(\\s*)((?:\\d+\\.)|[*+-])\\s(.*)((?:\\n\\s{2,}.*)*)(?=\\n*(?:(?:\\d+\\.)|[*+-])\\s|\\n*$)",
    )
    use acc, match <- list.fold(matches, "")
    acc <> parse_list_item(match, options)
  }

  use exp <- to_regex(
    "^(?:\\s*)[*+-]\\s",
    regex.Options(case_insensitive: True, multi_line: False),
    text,
  )
  let tag = case regex.check(exp, text) {
    True -> "ul"
    False -> "ol"
  }

  form_element(tag, parse(), options)
}

fn parse_lists(text: String, options: Options) {
  use matches <- replace_all(
    text,
    // match all lists with their list items
    "^(\\s*(([-+*]|\\d+\\.)\\s.*)+(\n\\s{2,}.+)*)+",
  )
  use acc, match <- list.fold(matches, text)
  string.replace(acc, match.content, parse_list(match.content, options))
}

fn parse_paragraphs(text: String, options: Options) {
  text
  |> replace("^(?![ \t]*<)(.+?)(?=\n\\s*\n|$)", fn(matches) {
    list.fold(matches, "", fn(acc, match) {
      acc
      <> case match == "" {
        True -> form_element("div", "", options)
        False -> form_element("p", match, options)
      }
    })
  })
}

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
  > sub quote

> This is an important
> quote
> to match multi line
>> also a nested quote

Paragraph

1. Ordered list 1
1. Ordered list 2
    - Inner 1
    - Inner 2
"
  |> render
  |> io.println
}
