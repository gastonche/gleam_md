import gleam/dict
import gleam/list
import gleeunit
import gleeunit/should
import render_md

pub fn main() {
  gleeunit.main()
}

fn test_list(items: List(a), cb: fn(a) -> Nil) {
  list.each(items, cb)
}

fn test_list_equal(items: List(#(String, String))) {
  use item <- test_list(items)
  render_md.render(item.0)
  |> should.equal(item.1)
}

pub fn header_1_test() {
  render_md.render("# header 1")
  |> should.equal("<h1 class=\"\">header 1</h1>")
}

pub fn alt_header_1_test() {
  render_md.render("header 1\n======")
  |> should.equal("<h1 class=\"\">header 1</h1>")
}

pub fn header_2_test() {
  render_md.render("## header 2")
  |> should.equal("<h2 class=\"\">header 2</h2>")
}

pub fn alt_header_2_test() {
  render_md.render("header 2\n------")
  |> should.equal("<h2 class=\"\">header 2</h2>")
}

pub fn header_3_test() {
  render_md.render("### header 3")
  |> should.equal("<h3 class=\"\">header 3</h3>")
}

pub fn header_4_test() {
  render_md.render("#### header 4")
  |> should.equal("<h4 class=\"\">header 4</h4>")
}

pub fn header_5_test() {
  render_md.render("##### header 5")
  |> should.equal("<h5 class=\"\">header 5</h5>")
}

pub fn header_6_test() {
  render_md.render("###### header 6")
  |> should.equal("<h6 class=\"\">header 6</h6>")
}

pub fn bold_test() {
  [
    #(
      "**long bold text in here**",
      "<strong class=\"\">long bold text in here</strong>",
    ),
    #("**bold**", "<strong class=\"\">bold</strong>"),
  ]
  |> test_list_equal
}

pub fn em_test() {
  [
    #("*long em text in here*", "<em class=\"\">long em text in here</em>"),
    #("*em*", "<em class=\"\">em</em>"),
    #("*mixed em left**", "<em class=\"\">mixed em left</em>*"),
    #("**mixed em right*", "<em class=\"\">*mixed em right</em>"),
    #("A*cat*meow", "<p class=\"\">A<em class=\"\">cat</em>meow</p>"),
    #(
      "Italicized text is the _cat's meow_.",
      "<p class=\"\">Italicized text is the <em class=\"\">cat's meow</em>.</p>",
    ),
  ]
  |> test_list_equal
}

pub fn links_test() {
  render_md.render("[Markdown Guide](https://www.markdownguide.org/)")
  |> should.equal(
    "<a class=\"\" href=\"https://www.markdownguide.org/\">Markdown Guide</a>",
  )
}

pub fn img_test() {
  render_md.render(
    "![Markdown Logo](https://markdown-here.com/img/icon256.png)",
  )
  |> should.equal(
    "<img class=\"\" src=\"https://markdown-here.com/img/icon256.png\" alt=\"Markdown Logo\" />",
  )
}

pub fn horizontal_rule_test() {
  use item <- test_list(["***", "****", "---", "------", "___", "_______"])
  render_md.render(item)
  |> should.equal("<hr class=\"\" />")
}

pub fn block_quote_test() {
  [
    #(
      "> Dorothy followed her through many of the beautiful rooms in her castle.",
      "<blockqoute class=\"\">\n<p class=\"\">Dorothy followed her through many of the beautiful rooms in her castle.</p>\n</blockqoute>",
    ),
    #(
      "> Dorothy followed her through many of the beautiful rooms in her castle.
>
> The Witch bade her clean the pots and kettles and sweep the floor and keep the fire fed with wood.",
      "<blockqoute class=\"\">\n<p class=\"\">Dorothy followed her through many of the beautiful rooms in her castle.</p>\n<blockqoute class=\"\">\n\n</blockqoute>\n<p class=\"\">The Witch bade her clean the pots and kettles and sweep the floor and keep the fire fed with wood.</p>\n</blockqoute>",
    ),
    #(
      "> Dorothy followed her through many of the beautiful rooms in her castle.
>
>> The Witch bade her clean the pots and kettles and sweep the floor and keep the fire fed with wood.",
      "<blockqoute class=\"\">\n<p class=\"\">Dorothy followed her through many of the beautiful rooms in her castle.</p>\n<blockqoute class=\"\">\n<blockqoute class=\"\">\n<p class=\"\">The Witch bade her clean the pots and kettles and sweep the floor and keep the fire fed with wood.</p>\n</blockqoute>\n</blockqoute>\n</blockqoute>",
    ),
    #(
      "> #### The quarterly results look great!
>
> - Revenue was off the chart.
> - Profits were higher than ever.
>
>  *Everything* is going according to **plan**.",
      "<blockqoute class=\"\">\n<p class=\"\">#### The quarterly results look great!</p>\n<blockqoute class=\"\"<blockqoute class=\"\">\n\n</blockqoute>\n\n</blockqoute<blockqoute class=\"\">\n\n</blockqoute>\n<ul class=\"\"><li class=\"\">Revenue was off the chart.</li><li class=\"\">Profits were higher than ever.</li></ul>\n<blockqoute class=\"\"<blockqoute class=\"\">\n\n</blockqoute>\n\n</blockqoute<blockqoute class=\"\">\n\n</blockqoute>\n <em class=\"\"<blockqoute class=\"\"<blockqoute class=\"\">\n\n</blockqoute>\n\n</blockqoute<blockqoute class=\"\">\n\n</blockqoute>Everything</emis going according to <strong class=\"\"<blockqoute class=\"\"<blockqoute class=\"\">\n\n</blockqoute>\n\n</blockqoute<blockqoute class=\"\">\n\n</blockqoute>plan</strong<blockqoute class=\"\"<blockqoute class=\"\">\n\n</blockqoute>\n\n</blockqoute<blockqoute class=\"\">\n\n</blockqoute>.\n</blockqoute>",
    ),
  ]
  |> test_list_equal
}

pub fn paragraph_test() {
  [
    #(
      "I really like using Markdown.",
      "<p class=\"\">I really like using Markdown.</p>",
    ),
    #(
      "I think I'll use it to format all of my documents from now on.",
      "<p class=\"\">I think I'll use it to format all of my documents from now on.</p>",
    ),
  ]
  |> test_list_equal
}

pub fn list_test() {
  [
    #(
      "1. First item
2. Second item
3. Third item
4. Fourth item",
      "<ol class=\"\"><li class=\"\">First item</li><li class=\"\">Second item</li><li class=\"\">Third item</li><li class=\"\">Fourth item</li></ol>",
    ),
    #(
      "1. First item
1. Second item
1. Third item
1. Fourth item",
      "<ol class=\"\"><li class=\"\">First item</li><li class=\"\">Second item</li><li class=\"\">Third item</li><li class=\"\">Fourth item</li></ol>",
    ),
    #(
      "1. First item
8. Second item
3. Third item
5. Fourth item",
      "<ol class=\"\"><li class=\"\">First item</li><li class=\"\">Second item</li><li class=\"\">Third item</li><li class=\"\">Fourth item</li></ol>",
    ),
    #(
      "1. First item
2. Second item
3. Third item
    1. Indented item
    2. Indented item
4. Fourth item",
      "<ol class=\"\"><li class=\"\">First item</li><li class=\"\">Second item</li><li class=\"\">Third item<ol class=\"\"><li class=\"\">Indented item</li><li class=\"\">Indented item</li></ol></li><li class=\"\">Fourth item</li></ol>",
    ),
    #(
      "- First item x
- Second item
- Third item
- Fourth item",
      "<ul class=\"\"><li class=\"\">First item x</li><li class=\"\">Second item</li><li class=\"\">Third item</li><li class=\"\">Fourth item</li></ul>",
    ),
    #(
      "* First item
* Second item
* Third item
* Fourth item",
      "<ul class=\"\"><li class=\"\">First item</li><li class=\"\">Second item</li><li class=\"\">Third item</li><li class=\"\">Fourth item</li></ul>",
    ),
    #(
      "+ First item
+ Second item
+ Third item
+ Fourth item",
      "<ul class=\"\"><li class=\"\">First item</li><li class=\"\">Second item</li><li class=\"\">Third item</li><li class=\"\">Fourth item</li></ul>",
    ),
    #(
      "- First item
- Second item
- Third item
    - Indented item
    - Indented item
- Fourth item",
      "<ul class=\"\"><li class=\"\">First item</li><li class=\"\">Second item</li><li class=\"\">Third item<ul class=\"\"><li class=\"\">Indented item</li><li class=\"\">Indented item</li></ul></li><li class=\"\">Fourth item</li></ul>",
    ),
    #(
      "* This is the first list item.
* Here's the second list item.

    I need to add another paragraph below the second list item.

* And here's the third list item.",
      "<ul class=\"\"><li class=\"\">This is the first list item.</li><li class=\"\">Here's the second list item.<p class=\"\">I need to add another paragraph below the second list item.</p></li><li class=\"\">And here's the third list item.</li></ul>",
    ),
    #(
      "* This is the first list item.
* Here's the second list item.

    > A blockquote would look great below the second list item.

* And here's the third list item.",
      "<ul class=\"\"><li class=\"\">This is the first list item.</li><li class=\"\">Here's the second list item.<blockqoute class=\"\">\n<p class=\"\">A blockquote would look great below the second list item.</p>\n</blockqoute></li><li class=\"\">And here's the third list item.</li></ul>",
    ),
  ]
  |> test_list_equal
}

const text = "
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
"

pub fn general_test() {
  text
  |> render_md.render
  |> should.equal(
    "<h1 class=\"\">Header 1 goes here</h1>\n<p class=\"\">sub title</p>\n<h2 class=\"\">Header 2</h2>\n\n<h1 class=\"\">header 1</h1>\n\n<h2 class=\"\">header 2</h2>\n\n<em class=\"\">Italic</em>, <em class=\"\">italic</em> and <strong class=\"\">bold</strong>.\n\n<a class=\"\" href=\"https://www.markdownguide.org/\">Markdown Guide</a>\n\n<img class=\"\" src=\"https://markdown-here.com/img/icon256.png\" alt=\"Markdown Logo\" />\n\n<hr class=\"\" />\n\n<blockqoute class=\"\">\n<p class=\"\">Block<p class=\"\">quote</p></p>\n</blockqoute>\n<ul class=\"\"><li class=\"\">List item 1</li><li class=\"\">List item 2</li></ul>\n\n<blockqoute class=\"\">\n<p class=\"\">This is an important</p>\n<p class=\"\">quote</p>\n<p class=\"\">to match multi line</p>\n<blockqoute class=\"\">\nalso a nested <p class=\"\">quote</p>\n</blockqoute>\n</blockqoute>\n\n<p class=\"\">Paragraph</p>\n<ol class=\"\"><li class=\"\">Ordered list 1</li><li class=\"\">Ordered list 2<ul class=\"\"><li class=\"\">Inner 1</li><li class=\"\">Inner 2</li></ul></li></ol>",
  )
}

pub fn custom_classes_test() {
  text
  |> render_md.render_with_options(
    render_md.Options(
      class_names: dict.from_list([#("h1", "heading1"), #("h2", "heading2")]),
    ),
  )
  |> should.equal(
    "<h1 class=\"heading1\">Header 1 goes here</h1>\n<p class=\"\">sub title</p>\n<h2 class=\"heading2\">Header 2</h2>\n\n<h1 class=\"heading1\">header 1</h1>\n\n<h2 class=\"heading2\">header 2</h2>\n\n<em class=\"\">Italic</em>, <em class=\"\">italic</em> and <strong class=\"\">bold</strong>.\n\n<a class=\"\" href=\"https://www.markdownguide.org/\">Markdown Guide</a>\n\n<img class=\"\" src=\"https://markdown-here.com/img/icon256.png\" alt=\"Markdown Logo\" />\n\n<hr class=\"\" />\n\n<blockqoute class=\"\">\n<p class=\"\">Block<p class=\"\">quote</p></p>\n</blockqoute>\n<ul class=\"\"><li class=\"\">List item 1</li><li class=\"\">List item 2</li></ul>\n\n<blockqoute class=\"\">\n<p class=\"\">This is an important</p>\n<p class=\"\">quote</p>\n<p class=\"\">to match multi line</p>\n<blockqoute class=\"\">\nalso a nested <p class=\"\">quote</p>\n</blockqoute>\n</blockqoute>\n\n<p class=\"\">Paragraph</p>\n<ol class=\"\"><li class=\"\">Ordered list 1</li><li class=\"\">Ordered list 2<ul class=\"\"><li class=\"\">Inner 1</li><li class=\"\">Inner 2</li></ul></li></ol>",
  )
}
