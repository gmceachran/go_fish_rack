require_relative '../server'

RSpec.describe Server do

  it 'is possible to join a game', :js do
    join_game('John')
    expect(page).to have_content('Players')
    expect(page).to have_content('John')
  end

  it "when two player's join, both names show up" do
    join_game('John')
    join_game('Jane')

    expect(page).to have_content('Players')
    expect(page).to have_content('John')
    expect(page).to have_content('Jane')
  end

  it "they can't join a game without an api_key" do
    visit '/game'
    expect(page).to have_current_path('/')
  end

  it 'game starts' do
    join_game('John')
    find('.accordion').click

    expect(page).to have_css '.accordion'
    expect(page).to have_css '.playing-card'
  end

  def join_game(name)
    visit '/'
    fill_in :name, with: name
    click_on 'Join'
  end
end
