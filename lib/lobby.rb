require_relative 'go_fish/game'

class Lobby
  attr_accessor :games

  def initalize
    @games = []
  end

  def create_game(number_of_players)
    games << Game.new
  end

  # my issue with this is that the client shouldn't even be able to click on this if
  # the game is maxed out
  def add_client(game, name)
    if game.number_of_players < game.allowed_player_count
      game.add_player(name)
    end
  end
end
