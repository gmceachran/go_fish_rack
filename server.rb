require 'sinatra/contrib/all'
require 'slim'
require 'rack/contrib'
require_relative 'lib/go_fish/game'
require_relative 'lib/go_fish/player'

class Server < Sinatra::Base
  enable :sessions

  register Sinatra::RespondWith
  use Rack::JSONBodyParser

  def self.game = @@game ||= Game.new
  def self.api_keys = @@api_keys ||= {}

  get '/' do
    slim :login
  end

  post '/join' do
    name = params[:name]
    api_key = Base64.urlsafe_encode64(name)
    session[:api_key] = api_key

    self.class.api_keys[api_key] = name
    game = self.class.game
    game.add_player(name)

    respond_to do |format|
      format.html { redirect '/game' }
      format.json do
        { 'api_key' => api_key }.to_json
      end
    end
  end

  get '/game' do
    authenticate!

    respond_to do |format|
      format.html do
        redirect '/waiting' unless enough_players?
        game, player, opponents, is_clients_turn = turn_state
        slim :game, locals: { game: game, player: player, opponents: opponents, is_clients_turn: is_clients_turn }
      end

      format.json do
        { turn_index: 0, players: [], hand: [], round_results: [] }.to_json
      end
    end
  end

  get '/waiting' do
    redirect '/game' if enough_players?

    slim :waiting
  end

  post '/ask' do
    game = self.class.game
    player = game.players.detect { |player| player.name == find_name }
    turn_result = game.play_turn(player.name, params[:rank], params[:opponent])
    game.advance_turn unless turn_result.go_again
    redirect '/winner' if game.winner
    redirect '/game'
  end

  get '/winner' do
    slim :winner, locals: { winner: self.class.game.winner }
  end

  def self.reset!
    @@game = nil
    @@api_keys = nil
  end

  private

  def authenticate!
    return check_keys unless request.accept.any? { _1.entry == "application/json" }
    halt 401 unless auth.provided? && auth.basic? && self.class.api_keys.key?(auth.username)
  end

  def auth = Rack::Auth::Basic::Request.new(request.env)

  def check_keys
    api_keys = self.class.api_keys
    redirect '/' if api_keys.empty? ||
                    !api_keys.key?(session[:api_key]) ||
                    !session.key?(:api_key)
  end

  def enough_players? = self.class.api_keys.length >= 2
  def find_name = self.class.api_keys[session[:api_key]]

  def turn_state
    game = self.class.game
    game.start unless game.started
    redirect '/winner' if self.class.game.winner

    player = game.players.detect { |player| player.name == find_name }
    opponents = game.players - [player]
    is_clients_turn = game.current_player == player

    [game, player, opponents, is_clients_turn]
  end
end
