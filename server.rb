require 'sinatra'
require 'slim'
require_relative 'lib/go_fish/game'
require_relative 'lib/go_fish/player'

class Server < Sinatra::Base
  enable :sessions

  def self.game
    @@game ||= Game.new
  end

  def self.api_keys
    @@api_keys ||= {}
  end

  get '/' do
    slim :login
  end

  post '/join' do
    api_key = Base64.urlsafe_encode64(params["name"])
    session[:api_key] = api_key
    self.class.api_keys[api_key] = params[:name]

    game = self.class.game
    player_name = find_name
    game.add_player(player_name)

    redirect '/game'
  end

  get '/game' do
    check_keys
    redirect '/waiting' unless enough_players?

    game = self.class.game
    game.start unless game.started

    slim :game, locals: {
      names: self.class.api_keys.map { |key, name| name },
      game: game
    }
  end

  get '/waiting' do
    redirect '/game' if enough_players?

    slim :waiting
  end

  def self.reset!
    @@game = nil
    @@api_keys = nil
  end

  private

  def check_keys
    api_keys = self.class.api_keys
    redirect '/' if api_keys.empty?
    redirect '/' unless session.key?(:api_key)
    api_keys.each { |api_key, name| return if session[:api_key] == api_key }
    redirect '/'
  end

  def find_name = self.class.api_keys[session[:api_key]]
  def enough_players? = self.class.api_keys.length >= 2
end
