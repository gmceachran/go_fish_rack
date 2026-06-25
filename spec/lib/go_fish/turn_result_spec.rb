require_relative '../../../lib/go_fish/turn_result'
require_relative '../../../lib/go_fish/card'
require_relative '../../../lib/go_fish/player'

describe TurnResult do
  describe '#for_current' do
    let(:card1)  { Card.new('K', 'Clubs') }
    let(:card2)  { Card.new('K', 'Diamonds') }
    let(:player_name) { 'Player 1' }
    let(:opponent_name) { 'Player 2' }
    let(:for_current) { turn_result.for_current(player_name, opponent_name) }

    context 'when player takes from opponent' do
      let(:turn_result) { described_class.new(go_fish: false, cards: [card1, card2]) }
      let(:announcement) { /Player 1.*2 cards.*Player 2/i }

      it 'announces player took from opponent' do
        expect(for_current.last).to match announcement
      end
    end

    context 'when player takes from deck' do
      let(:go_fish) { 'Go Fish!' }
      let(:turn_result) { described_class.new(go_fish: true) }

      it 'announces go fish to all clients' do
        expect(for_current).to include go_fish
      end

      context 'when deck is empty' do
        let(:empty_announcement) { "Deck is empty! Next player's turn." }
        before { turn_result.deck_empty = true }

        it 'announces deck is empty' do
          expect(for_current.last).to eq empty_announcement
        end
      end

      context 'when deck is not empty' do

        context 'when deck has requested card' do
          let(:go_again_announcement) { 'Player 1 gets to go again!' }
          before { turn_result.go_again = true }

          it 'announces player gets to go again' do
            expect(for_current.last).to eq go_again_announcement
          end
        end

        context 'when deck does not have requested card' do
          let(:turn_over_announcement) { 'Turn over.' }

          it 'announces player turn is over' do
            expect(for_current.last).to eq turn_over_announcement
          end
        end
      end
    end
  end

  describe '#data' do
    let(:player_name) { "John" }
    let(:turn_result) do
      described_class.new(cards: [Card.new('A', 'Spades')], go_fish: true)
    end

    let (:mock_data) do
      {
        current_player: player_name,
        rank: 'A',
        went_fishing: true,
        # TODO: Refactor to call for current
        display: ''
      }
    end

    it 'returns a hash containing data for api request' do
      expect(turn_result.data(player_name)).to eq mock_data
    end
  end
end
