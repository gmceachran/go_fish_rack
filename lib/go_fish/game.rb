require_relative 'player'
require_relative 'turn_result'
require_relative 'deck'

class Game
  attr_reader :players, :deck, :turn_results
  STARTING_HAND = 7

  def initialize(player_ids)
    @players = player_ids.map { |id| Player.new(id) }
    @deck = Deck.new
    @turn_results = []
  end

  def turn_result = turn_results.last

  def start
    deck.shuffle
    deal(players, STARTING_HAND)
  end

  def play_turn(player_id, rank, opponent_id)
    player, opponent = players[player_id], players[opponent_id]
    opponent_cards_of_rank = opponent.cards_of_rank_given(rank)

    handle_take_cards(player, opponent_cards_of_rank, rank)
    turn_result
  end

  def winner
    return nil unless players.all? { |player| player.hand.empty? }

    winner = players.max_by do |player|
      best_book_value = player.books.map { |book| book.value }.max || -1
      [player.books.length, best_book_value]
    end
    winner.id
  end

  def opponent_validation(active_player_id, input)
    return { invalid: :format } unless input.match?(/\A\d+\z/)

    id = input.to_i - 1
    return { invalid: :opponent_id } if id == active_player_id
    return { invalid: :opponent_id } unless players.any? { |player| player.id == id }

    { valid: true }
  end

  def rank_validation(active_player_id, input)
    return { invalid: :format } unless Card::RANKS.include?(input)
    return { invalid: :rank } unless players[active_player_id].cards_of_rank?(input)

    { valid: true }
  end

  def active_player_hand_empty?(id)
    players[id].hand.empty?
  end

  private

  def deal(players, num)
      players.each do |player|
      num.times do
        card = deck.top_card
        player.hand << card
      end
    end
  end

  def handle_take_cards(player, opponent_cards, rank)
    if opponent_cards.any?
      take_from_opponent(player, opponent_cards)
    else
      take_from_deck(player, rank)
    end
  end

  def take_from_opponent(player, cards)
    turn_results << TurnResult.new(go_fish: false, go_again: true)
    turn_result.cards = cards
    player.take cards
    turn_result.book_made = player.create_book_if_possible
  end

  def take_from_deck(player, rank)
    turn_results << TurnResult.new(go_fish: true)
    return empty_deck if deck.empty?

    card = deck.top_card
    player.take([card])
    turn_result.cards << card
    turn_result.go_again = card.rank == rank
    turn_result.book_made = player.create_book_if_possible
  end

  def empty_deck
    turn_result.deck_empty = true
    turn_result
  end
end
