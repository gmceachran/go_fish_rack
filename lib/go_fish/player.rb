require_relative 'book'

class Player
  attr_reader :name
  attr_accessor :hand, :books

  def initialize(name)
    @name = name
    @hand = []
    @books = []
  end

  def hand_size = hand.length

  def take(new_cards)
    new_cards.each { |card| hand << card }
    new_cards
  end

  def cards_of_rank_given(rank)
    cards = hand.filter { |card| card.rank == rank }
    return cards if cards.empty?
    cards.each { |card| hand.delete(card) }
  end

  def show_hand
    self.hand = hand.sort_by { |card| card.value }
    displayed_hand = hand.map { |card| "- #{card}" }
    displayed_hand.unshift '', 'Your hand:'
    displayed_hand = show_books(displayed_hand) if books.any?
    displayed_hand
  end

  def create_book_if_possible
    cards_by_rank = hand.group_by(&:rank)
    cards_by_rank.each do |rank, cards|
      if cards.length == 4
        books << Book.new(rank)
        cards.each { |card| hand.delete card }
        return true
      end
    end
    false
  end

  def cards_of_rank?(rank)
    hand.any? { |card| card.rank == rank }
  end

  private

  def show_books(displayed_hand)
    displayed_hand.push '', 'Books:'
    books.each do |book|
      displayed_hand << "- rank: #{book.rank}"
    end

    displayed_hand
  end
end
