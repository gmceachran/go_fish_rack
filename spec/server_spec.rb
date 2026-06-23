require_relative '../server'

RSpec.describe Server do

  after do
    Server.reset!
  end

  it 'is possible to join a game' do
    join_game('John')
    join_game('Jane')
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

  context 'when there are not enough players to join' do
    it 'client is redirected to a waiting page' do
      join_game('John')
      expect(page).to have_content 'Waiting for players to join'
    end
  end

  context 'when there are enough players to join' do
    it 'cards are dealt' do
      join_game('John')
      join_game('Jane')

      expect(page).to have_css '.accordion'
    end
  end

  def join_game(name)
    visit '/'
    fill_in :name, with: name
    click_on 'Join'
  end
end
