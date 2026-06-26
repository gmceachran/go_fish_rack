require 'sinatra/contrib/all'
require 'slim'
require 'rack/contrib'
require_relative 'lib/go_fish/game'

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

    api_keys[api_key] = name
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
        bot_name = find_name
        game.as_json(bot_name).to_json
      end
    end
  end

  post '/game' do
    authenticate!
    player = game.players.detect { |player| player.name == find_name }
    turn_result = game.play_turn(player.name, params[:rank], params[:player])
    game.advance_turn unless turn_result.go_again
    game.as_json(find_name).to_json
  end

  get '/waiting' do
    redirect '/game' if enough_players?

    slim :waiting
  end

  post '/ask' do
    player = game.players.detect { |player| player.name == find_name }
    turn_result = game.play_turn(player.name, params[:rank], params[:opponent])
    game.advance_turn unless turn_result.go_again
    redirect '/winner' if game.winner
    redirect '/game'
  end

  get '/winner' do
    slim :winner, locals: { winner: game.winner }
  end

  def self.reset!
    @@game = nil
    @@api_keys = nil
  end

  private

  def authenticate!
    return check_keys unless bot_request?
    halt 401 unless auth.provided? && auth.basic? && api_keys.key?(auth.username)
  end

  def auth = Rack::Auth::Basic::Request.new(request.env)

  def check_keys
    redirect '/' if api_keys.empty? ||
    !api_keys.key?(session[:api_key]) ||
    !session.key?(:api_key)
  end

  def find_name
    return api_keys[session[:api_key]] unless bot_request?
    api_keys[auth.username]
  end

  def turn_state
    game.start unless game.started
    redirect '/winner' if game.winner

    player = game.players.detect { |player| player.name == find_name }
    opponents = game.players - [player]
    is_clients_turn = game.current_player == player

    [game, player, opponents, is_clients_turn]
  end

  def enough_players? = api_keys.length >= 2
  def bot_request? = request.accept.any? { _1.entry == "application/json" }
  def game = self.class.game
  def api_keys = self.class.api_keys
end
