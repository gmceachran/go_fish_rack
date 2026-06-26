require_relative '../../../lib/go_fish/game'

describe Game do
  let(:player_names) { ["John", "Farquad"] }
  let(:game) { described_class.new }
  let(:players) { game.players }
  let(:deck) { game.deck }

  before do
    player_names.each { |name| game.add_player name }
  end

  describe '#start' do
    it 'shuffles cards' do
      unshuffled_hand = deck.cards[0..6]
      game.start
      shuffled_hand = players.first.hand
      expect(shuffled_hand).not_to eq unshuffled_hand
    end

    it "each player's is dealt seven cards" do
      game.start
      players.each { |player| expect(player.hand_size).to be 7 }
    end
  end

  describe '#play_turn' do
    let(:player_card) { Card.new('3', 'Spades') }
    let(:opponent_card) { Card.new('4', 'Clubs') }
    let(:requested_card) { Card.new('3', 'Clubs') }
    let(:turn_result) { game.play_turn('John', '3', 'Farquad') }

    before do
      game.start
      players.first.hand = [player_card]
      players.last.hand = [requested_card, opponent_card]
    end

    context "when a player's hand is empty" do
      let(:player_name) { 'John' }
      let(:opponent_name) { 'Farquad' }
      let(:rank) { '3' }

      before { game.players.last.hand = [] }

      context 'when the deck is not empty' do
        it 'draws them a card from the deck' do
          expect(game.players.last.hand).to be_empty
          game.play_turn(player_name, rank, opponent_name)
          expect(game.players.last.hand.length).to be 1
        end
      end

      context 'when the deck is empty' do
        before { game.deck.cards = [] }

        it 'does nothing' do
          expect(game.players.last.hand).to be_empty
          game.play_turn(player_name, rank, opponent_name)
          expect(game.players.last.hand).to be_empty
        end
      end
    end

    it 'returns a TurnResult object' do
      expect(turn_result).to be_a TurnResult
    end

    context 'opponent has card' do

      it 'removes card from opponent and gives to player' do
        turn_result
        expect(players.first.hand).to include requested_card
        expect(players.last.hand).to eq [opponent_card]
      end

      it 'turn result is populated with correct data' do
        expect(turn_result.go_fish).to be false
        expect(turn_result.cards).to include requested_card
      end
    end

    context 'opponent does not have card' do

      context 'when deck is empty' do
        let(:turn_result) { game.play_turn('John', '3', 'Farquad') }
        before do
          deck.cards = []
          players.first.hand = []
          players.last.hand = [Card.new('2', 'Spades')]
        end

        it 'it player takes no cards' do
          turn_result
          expect(players.first.hand).to be_empty
        end

        it 'TurnResult is populated with oppropriate data' do
          expect(turn_result.deck_empty).to be true
        end
      end

      context 'when deck is not empty' do
        before do
          players.last.hand = [opponent_card]
          deck.cards = [requested_card]
        end

        let(:turn_result) { game.play_turn('John', '3', 'Farquad') }

        it 'removes card from deck and gives to player' do
          turn_result
          expect(players.first.hand).to include requested_card
          expect(deck.cards).not_to include requested_card
        end

        it 'turn result is populated with appropriate data' do
          expect(turn_result.go_fish).to be true
          expect(turn_result.cards).to include requested_card
        end

        context 'deck has card' do
          it 'turn result is populated with the appropriate data' do
            expect(turn_result.go_again).to be true
          end
        end

        context 'deck does not have card' do
          let(:other_card) { Card.new('10', 'Spades') }

          before do
            players.last.hand = [opponent_card]
            deck.cards = [other_card]
          end

          it 'turn result is populated with the appropriate data' do
            expect(turn_result.go_again).to be false
          end
        end
      end
    end
  end

  describe '#winner' do

    context 'when one or more player has cards' do
      before { players.first.hand = [Card.new('A', 'Spades')] }

      it 'winner returns nil' do
        expect(game.winner).to be_nil
      end
    end

    context 'when no player has cards' do
      let(:winner_name) { "John" }

      context 'when one player has more books than the others' do
        before do
          players.first.books.push Book.new('3'), Book.new('4')
          players.last.books.push Book.new('5')
        end

        it 'winner returns that player name' do
          expect(game.winner).to eq winner_name
        end
      end


      context 'when the two players with the most books have the same amount' do
        before do
          players.first.books.push Book.new('K')
          players.last.books.push Book.new('Q')
        end

        it 'winner returns the id of the player with the highest rank' do
          expect(game.winner).to eq winner_name
        end
      end
    end
  end

  # describe '#opponent_validation' do

  #   context 'when input is valid' do
  #     let(:valid) { { valid: true } }

  #     it 'returns valid' do
  #       expect(game.opponent_validation("John", '2')).to eq valid
  #     end
  #   end

  #   context 'when input is invalid' do
  #     let(:invalid_format) { { invalid: :format } }
  #     let(:invalid_opponent) { { invalid: :opponent_id } }

  #     context 'when input is not an integer' do
  #       it 'returns invalid format' do
  #         expect(game.opponent_validation(0, 'invalid')).to eq invalid_format
  #       end
  #     end

  #     context 'when input is active_player_id' do
  #       it 'returns invalid opponent' do
  #         expect(game.opponent_validation(0, '0')).to eq invalid_opponent
  #       end
  #     end

  #     context 'when input is not a valid player id' do
  #       it 'returns invalid opponent' do
  #         expect(game.opponent_validation(0, '3')).to eq invalid_opponent
  #       end
  #     end
  #   end
  # end

  # describe '#rank_validation' do

  #   context 'when input is valid' do
  #     let(:valid) { { valid: true } }
  #     before do
  #       players.first.hand = [Card.new('3', 'Spades')]
  #     end

  #     it 'returns invalid format' do
  #       expect(game.rank_validation(0, '3')).to eq valid
  #     end

  #   end

  #   context 'when input is invalid' do
  #     let(:invalid_format) { { invalid: :format } }
  #     let(:invalid_rank) { { invalid: :rank } }

  #     context 'when input is not a valid format' do
  #       it 'returns invalid format' do
  #         expect(game.rank_validation(0, 'invalid')).to eq invalid_format
  #       end
  #     end

  #     context 'when user does not have a card of a given rank' do
  #       it 'returns invalid rank' do
  #         expect(game.rank_validation(0, '3')).to eq invalid_rank
  #       end
  #     end
  #   end
  # end

  describe '#active_player_hand_empty' do
    let(:id) { 0 }

    context "when active player's hand is empty" do
      it 'returns true' do
        expect(game.active_player_hand_empty?(id)).to be true
      end
    end

    context "when active player's hand is not empty" do
      before do
        players.first.hand = [Card.new('K', 'Spades')]
      end

      it 'returns false' do
        expect(game.active_player_hand_empty?(id)).to be false
      end
    end
  end

  describe '#as_json' do
    let(:player_name) { "John" }
    let(:bot_name) { "Farquad" }

    context 'when turn results is not empty' do
      let(:turn_result) { TurnResult.new(cards: [Card.new('A', 'Spades')], go_fish: true)}
      let(:mock_json) do
        {
          turn_index: 0,
          players: [
            {
              name: player_name,
              books: [],
              book_count: 0
            },
            {
              name: bot_name,
              books: [],
              book_count: 0
            }
          ],
          hand: [
            {
              rank: 'A',
              suit: 'Spades'
            }
          ],
          round_results: [
            {
              current_player: player_name,
              rank: 'A',
              went_fishing: true,
              display: ''
            }
          ]
        }
      end

      before do
        game.players.last.hand << Card.new('A', 'Spades')
        game.turn_results << turn_result
      end

      it 'returns json containing data for api request' do
        expect(game.as_json(bot_name)).to eq mock_json
      end
    end

    context 'when turn_results is empty' do

      it 'as_json returns an empty array for round_results instead of an object' do
        expect(game.as_json(bot_name)[:round_results]).to be_empty
      end
    end
  end
end
