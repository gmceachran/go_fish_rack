require 'sinatra'
require 'slim'
require_relative 'lib/go_fish/game'
require_relative 'lib/go_fish/player'

class Server < Sinatra::Base
  enable :sessions
  def self.game
    @@game ||=Game.new
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

    redirect '/game'
  end

  get '/game' do
    check_keys
    slim :game, locals: { names: self.class.api_keys.map { |key, name| name } }
  end

  def self.reset!
    @@game = nil
  end

  private

  def check_keys
    redirect '/' if self.class.api_keys.empty?
    redirect '/' unless session.key?(:api_key)

    self.class.api_keys.each do |api_key, name|
      return if session[:api_key] == api_key
    end

    redirect '/'
  end
end
