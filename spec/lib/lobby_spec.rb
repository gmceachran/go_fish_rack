require_relative '../../lib/lobby'

fdescribe Lobby do
  let(:lobby) { described_class.new }
  describe '#create_game' do
    it 'creates game with the appropriate number of players' do
      number_of_players = 2
      expect(lobby.create_game(number_of_players)).to be_a Game
    end
  end
end
