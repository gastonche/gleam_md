import gleeunit
import gleeunit/should
import gleam_md
import gleam/list

pub fn main() {
  gleeunit.main()
}

fn test_list(items: List(a), cb: fn(a) -> Nil) {
  list.each(items, cb)
}

fn test_list_equal(items: List(#(String, String))) {
  use item <- test_list(items)
  gleam_md.render(item.0)
  |> should.equal(item.1)
}

pub fn header_1_test() {
  gleam_md.render("# header 1")
  |> should.equal("<h1 class=\"\">header 1</h1>")
}

pub fn alt_header_1_test() {
  gleam_md.render("header 1\n======")
  |> should.equal("<h1 class=\"\">header 1</h1>")
}

pub fn header_2_test() {
  gleam_md.render("## header 2")
  |> should.equal("<h2 class=\"\">header 2</h2>")
}

pub fn alt_header_2_test() {
  gleam_md.render("header 2\n------")
  |> should.equal("<h2 class=\"\">header 2</h2>")
}

pub fn header_3_test() {
  gleam_md.render("### header 3")
  |> should.equal("<h3 class=\"\">header 3</h3>")
}

pub fn header_4_test() {
  gleam_md.render("#### header 4")
  |> should.equal("<h4 class=\"\">header 4</h4>")
}

pub fn header_5_test() {
  gleam_md.render("##### header 5")
  |> should.equal("<h5 class=\"\">header 5</h5>")
}

pub fn header_6_test() {
  gleam_md.render("###### header 6")
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
  gleam_md.render("[Markdown Guide](https://www.markdownguide.org/)")
  |> should.equal(
    "<a class=\"\" href=\"https://www.markdownguide.org/\">Markdown Guide</a>",
  )
}

pub fn img_test() {
  gleam_md.render("![Markdown Logo](https://markdown-here.com/img/icon256.png)")
  |> should.equal(
    "<img class=\"\" src=\"https://markdown-here.com/img/icon256.png\" alt=\"Markdown Logo\" />",
  )
}

pub fn horizontal_rule_test() {
  use item <- test_list(["***", "****", "---", "------", "___", "_______"])
  gleam_md.render(item)
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
      "<ol class=\"\"><li class=\"\">First item</li><li class=\"\">Second item</li></ol>\n<ol class=\"\"><li class=\"\">Third item</li><li class=\"\">Fourth item</li></ol>",
    ),
    #(
      "1. First item
1. Second item
1. Third item
1. Fourth item",
      "<ol class=\"\"><li class=\"\">First item</li><li class=\"\">Second item</li></ol>\n<ol class=\"\"><li class=\"\">Third item</li><li class=\"\">Fourth item</li></ol>",
    ),
    #(
      "1. First item
8. Second item
3. Third item
5. Fourth item",
      "<ol class=\"\"><li class=\"\">First item</li><li class=\"\">Second item</li></ol>\n<ol class=\"\"><li class=\"\">Third item</li><li class=\"\">Fourth item</li></ol>",
    ),
    #(
      "1. First item
2. Second item
3. Third item
    1. Indented item
    2. Indented item
4. Fourth item",
      "<ol class=\"\"><li class=\"\">First item</li><li class=\"\">Second item</li></ol>\n<ol class=\"\"><li class=\"\">Third item <ol class=\"\"><li class=\"\">Indented item</li><li class=\"\">Indented item</li></ol></li></ol>\n<ol class=\"\"><li class=\"\">Fourth item</li></ol>",
    ),
    #(
      "- First item
- Second item
- Third item
- Fourth item",
      "<ul class=\"\"><li class=\"\">First item</li><li class=\"\">Second item</li></ul>\n<ul class=\"\"><li class=\"\">Third item</li><li class=\"\">Fourth item</li></ul>",
    ),
    #(
      "* First item
* Second item
* Third item
* Fourth item",
      "<ul class=\"\"><li class=\"\">First item</li><li class=\"\">Second item</li></ul>\n<ul class=\"\"><li class=\"\">Third item</li><li class=\"\">Fourth item</li></ul>",
    ),
    #(
      "+ First item
+ Second item
+ Third item
+ Fourth item",
      "<ul class=\"\"><li class=\"\">First item</li><li class=\"\">Second item</li></ul>\n<ul class=\"\"><li class=\"\">Third item</li><li class=\"\">Fourth item</li></ul>",
    ),
    #(
      "- First item
- Second item
- Third item
    - Indented item
    - Indented item
- Fourth item",
      "<ul class=\"\"><li class=\"\">First item</li><li class=\"\">Second item</li></ul>\n<ul class=\"\"><li class=\"\">Third item <ul class=\"\"><li class=\"\">Indented item</li><li class=\"\">Indented item</li></ul></li></ul>\n<ul class=\"\"><li class=\"\">Fourth item</li></ul>",
    ),
  ]
  |> test_list_equal
}
