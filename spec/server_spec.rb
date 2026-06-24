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

  it "when two player's join, game page is rendered" do
    join_game('John')
    join_game('Jane')

    expect(page).to have_content('Game 1')
    expect(page).to have_content('Game Feed')
    expect(page).to have_content('Your Hand')
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
    let(:starting_hand_length) { 7 }

    before do
      join_game('Jane')
      join_game('John')
    end

    it 'game page renders' do
      expect(page).to have_css '.accordion'
    end

    it 'cards are dealt' do
      accordion = find_all('.accordion')[0]

      within accordion do
        playing_cards = find_all('img', visible: :all)
        expect(playing_cards.length).to be starting_hand_length
      end
    end

    it 'active hand increases/decreases per turn' do
      cards_before_take, cards_after_take = 1, 2
      set_cards_for_successful_take
      playing_cards = find_playing_cards
      expect(playing_cards.length).to be cards_before_take
      perform_turn
      playing_cards = find_playing_cards
      expect(playing_cards.length).to be cards_after_take
    end

    context 'when there is a winner' do
      before do
        Server.game.players.each { |player| player.hand = [] }
        Server.game.players.first.books << Book.new('3')
      end

      it 'players are redirected to a winner announcement' do
        visit '/game'
        expect(page).to have_content 'Jane wins!'
      end
    end
  end

  def join_game(name)
    visit '/'
    fill_in :name, with: name
    click_on 'Join'
  end

  def set_cards_for_successful_take
    Server.game.players.last.hand = [Card.new('A', 'Diamonds')]
    Server.game.players.first.hand = [Card.new('A', 'Spades')]
    Server.game.active_player_index = 1
    visit '/game'
  end

  def find_playing_cards
    within '#player-hand' do
      find_all('.playing-card')
    end
  end

  def perform_turn
    find('option', text: 'Jane', match: :first).select_option
    select 'A', from: 'rank'
    click_on 'Ask for Cards'
  end
end
