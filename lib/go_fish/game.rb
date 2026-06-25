require_relative 'player'
require_relative 'turn_result'
require_relative 'deck'

class Game
  attr_reader :players, :deck, :turn_results
  attr_accessor :started, :active_player_index
  STARTING_HAND = 7

  def initialize
    @players = []
    @deck = Deck.new
    @turn_results = []
    @started = false
    @active_player_index = 0
  end

  def add_player(player_name)
    players << Player.new(player_name)
  end

  def turn_result = turn_results.last

  def start
    deck.shuffle
    deal(players, STARTING_HAND)
    self.started = true
  end

  def play_turn(player_name, rank, opponent_name)
    player = players.detect { |player| player.name == player_name }
    opponent = players.detect { |player| player.name == opponent_name }
    opponent_cards_of_rank = opponent.cards_of_rank_given(rank)

    handle_take_cards(player, opponent_cards_of_rank, rank)
    turn_result
  end

  def advance_turn
    if active_player_index == (players.length - 1)
      self.active_player_index = 0
    else
      self.active_player_index += 1
    end
  end

  def current_player
    players[active_player_index]
  end

  def winner
    return nil unless players.all? { |player| player.hand.empty? }

    winner = players.max_by do |player|
      best_book_value = player.books.map { |book| book.value }.max || -1
      [player.books.length, best_book_value]
    end
    winner.name
  end

  # def opponent_validation(active_player_name, input)
  #   return { invalid: :format } unless input.match?(/\A\d+\z/)

  #   id = input.to_i - 1
  #   return { invalid: :opponent_name } if id == active_player_name
  #   return { invalid: :opponent_name } unless players.any? { |player| player.id == id }

  #   { valid: true }
  # end

  # def rank_validation(active_player_name, input)
  #   return { invalid: :format } unless Card::RANKS.include?(input)
  #   return { invalid: :rank } unless players[active_player_name].cards_of_rank?(input)

  #   { valid: true }
  # end

  def active_player_hand_empty?(name)
    # TODO: Needs to be refactored to find player by name
    players[name].hand.empty?
  end

  def as_json(bot_name)
    bot_hand = players.detect { |player| player.name == bot_name }.hand
    bot_hand_data = bot_hand.map { |card| card.data }
    active_player_name = players[active_player_index].name
    turn_result_data = [turn_results.last.data(active_player_name)]

    {
      turn_index: active_player_index,
      players: players.map { |player| player.data },
      hand: bot_hand_data,
      round_results: turn_result_data
    }.to_json
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
