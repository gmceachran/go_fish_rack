require 'sinatra'
require 'slim'

get '/' do
  slim :login
end
# shouldn't it be post?
