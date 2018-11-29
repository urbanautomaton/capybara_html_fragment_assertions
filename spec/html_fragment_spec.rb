# Test fails when nokogumbo is loaded, passes otherwise
require 'nokogumbo'

RSpec.describe 'asserting CSS in an HTML fragment' do
  include Capybara::DSL

  it 'finds a <td> element without a parent' do
    expect(Capybara.string("<td></td>")).to have_css('td')
  end
end
