class TurnResult
  attr_accessor :cards, :book_made, :go_again, :deck_empty
  attr_reader :go_fish

  EMPTY_ANNOUNCEMENT = "Deck is empty! Next player's turn."
  TURN_OVER_ANNOUNCEMENT = 'Turn over.'

  def initialize(go_fish: false,
                 cards: [],
                 book_made: false,
                 go_again: false,
                 deck_empty: false)

    @go_fish = go_fish
    @cards = cards
    @book_made = book_made
    @go_again = go_again
    @deck_empty = deck_empty
  end

  def for_current(player_name, opponent_name)
    return cards_from_opponent(player_name, opponent_name) unless go_fish

    announcement = ['', 'Go Fish!']
    return announcement << EMPTY_ANNOUNCEMENT if deck_empty

    return go_again_announcement(player_name, announcement) if go_again

    announcement << TURN_OVER_ANNOUNCEMENT
  end

  def data(name)
    {
      current_player: name,
      rank: cards.first.rank,
      went_fishing: go_fish,
      display: ''
    }
  end

  private

  def cards_from_opponent(player_name, opponent_name)
    cards_number = cards.length
    announcement = ['']
    if cards_number == 1
      announcement << "#{player_name} takes 1 card from #{opponent_name}"
    else
      announcement << "#{player_name} takes #{cards_number} cards from #{opponent_name}"
    end
    announcement
  end

  def go_again_announcement(player_name, announcement)
    go_again_announcement = "#{player_name} gets to go again!"
    announcement << go_again_announcement
  end
end
