require_relative '../../../lib/go_fish/player'
require_relative '../../../lib/go_fish/card'

describe Player do
  let(:name) { "John" }
  let(:player) { described_class.new(name) }

  describe '#hand_size' do
    before { player.hand << Card.new('A', 'Spades') }

    it "returns the length of player's hand" do
      one_card = 1
      expect(player.hand_size).to be one_card
    end
  end

  describe '#take' do
    let(:player_hand) { player.hand }
    let(:card1) { Card.new('3', 'Clubs') }
    let(:card2) { Card.new('3', 'Spades') }
    let(:card3) { Card.new('3', 'Diamonds') }
    let(:new_cards) { [card2, card3] }

    before { player_hand.push card1 }

    it 'pushes the given cards to hand' do
      player.take(new_cards)
      expect(player.hand.last).to eq card3
    end

    it 'returns taken cards' do
      cards_taken = player.take(new_cards)
      expect(cards_taken).to eq new_cards
    end
  end

  describe '#cards_of_rank_given' do
    let(:card1) { Card.new('5', 'Hearts') }
    let(:card2) { Card.new('5', 'Spades') }
    let(:card3) { Card.new('4', 'Hearts') }
    let(:card4) { Card.new('4', 'Spades') }
    let(:player) { Player.new(0) }

    before { player.hand.push card1, card2, card3, card4 }

    context 'cards of rank' do
      it 'deletes given cards' do
        requested_cards = player.cards_of_rank_given('5')
        requested_cards.each do |card|
          expect(player.hand).not_to include card
        end
      end

      it 'returns given cards' do
        cards_of_rank = player.cards_of_rank_given('5')
        expect(cards_of_rank).to eq [card1, card2]
      end
    end

    context 'no cards of rank' do
      it 'returns an empty array' do
        cards_of_rank = player.cards_of_rank_given('6')
        expect(cards_of_rank).to be_empty
      end
    end
  end

  describe '#show_hand' do
    let(:presented_hand) do
      [
        "",
        "Your hand:",
        "- Jack of Diamonds",
        "- King of Hearts",
        "",
        "Books:",
        "- rank: 3"
      ]
    end

    before do
      player.hand = [Card.new('K', 'Hearts'), Card.new('J', 'Diamonds')]
      player.books << Book.new('3')
    end

    it "returns a string presenting player's books and hand" do
      expect(player.show_hand).to eq presented_hand
    end
  end

  describe '#create_book_if_possible' do
    let(:card1) { Card.new('3', 'Clubs') }
    let(:card2) { Card.new('3', 'Hearts') }
    let(:card3) { Card.new('3', 'Spades') }
    let(:card4) { Card.new('3', 'Diamonds') }
    let(:card5) { Card.new('4', 'Diamonds') }

    context 'when hand has four cards of a rank' do
      before { player.hand.push card1, card2, card3, card4, card5 }
      it 'makes a book' do
        expect(player.books).to be_empty
        player.create_book_if_possible
        expect(player.books.first).to be_a Book
      end

      it 'deletes cards of given rank from player hand' do
        player.create_book_if_possible
        player.hand.each { |card| expect(card.rank).not_to eq '3' }
      end

      it 'does not delete cards of different ranks from player hand' do
        player.create_book_if_possible
        expect(player.hand).to include card5
      end

      it 'returns true' do
        expect(player.create_book_if_possible).to be true
      end
    end

    context 'when player does not have four cards of a given rank' do
      before { player.hand.push card1, card2, card3, card5 }

      it 'returns false' do
        expect(player.create_book_if_possible).to be false
      end

      it 'does not create a book' do
        player.create_book_if_possible
        expect(player.books).to be_empty
      end

      it 'does not mutate player hand' do
        unchanged_hand = [card1, card2, card3, card5]
        expect(player.hand).to eq unchanged_hand
      end
    end
  end

  describe '#cards_of_rank?' do
    before do
      player.hand << Card.new('3', 'Spades')
    end

    context 'when player has cards of a given rank' do
      it 'returns true' do
        expect(player.cards_of_rank?('3')).to be true
      end
    end

    context 'when player does not have cards of a given rank' do
      it 'returns false' do
        expect(player.cards_of_rank?('4')).to be false
      end
    end
  end
end
