require_relative '../server'

RSpec.describe Server do
  fit 'is possible to join a game', :js do
    visit '/'
    fill_in :name, with: 'John'
    click_on 'Join'
    expect(page).to have_content('Players')
    expect(page).to have_content('John')
  end
end
