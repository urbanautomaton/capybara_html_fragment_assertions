# Issue repro: capybara HTML fragment assertions

This is a reproduction of an issue introduced in Capybara 3.11.0, in
which if the [nokogumbo gem](https://github.com/rubys/nokogumbo) is
loaded, CSS-based assertions can fail on certain HTML fragment inputs.

## To reproduce

    bundle install
    bundle exec rspec

## Issue description

Since [version
3.11.0](https://github.com/teamcapybara/capybara/commit/7aa04bb5cf950e57bd4096ead5e0527ce185d0d2),
capybara uses nokogumbo to parse HTML input, if it's already loaded.

However, this parser has different behaviour when presented with HTML
fragments such as `"<td></td>"`:

Nokogiri:

    pry(main)> Nokogiri::HTML("<td></td>")
    => #(Document:0x3ff28738039c {
      name = "document",
      children = [
        #(DTD:0x3ff28d0d6280 { name = "html" }),
        #(Element:0x3ff28d0d0bb4 {
          name = "html",
          children = [
            #(Element:0x3ff28d0e517c {
              name = "body",
              children = [ #(Element:0x3ff28d0dbb04 { name = "td" })]
              })]
          })]
      })

Nokogumbo:

    pry(main)> Nokogiri::HTML5("<td></td>")
    => #(Document:0x3ff28d114094 {
      name = "document",
      children = [
        #(Element:0x3ff28d126320 {
          name = "html",
          children = [
            #(Element:0x3ff28d138160 { name = "head" }),
            #(Element:0x3ff28d13ce18 { name = "body" })]
          })]
      })

While Nokogiri preserves the orphaned `<td>` node in its AST, nokogumbo
strips it out. This leads to surprising failures when making assertions
about HTML fragments using capybara, e.g.

    # fails when nokogumbo is loaded
    expect(Capybara.string("<td></td>")).to have_css('td')
