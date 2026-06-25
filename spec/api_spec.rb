require_relative '../server'

describe Server, type: :request do
  include Rack::Test::Methods

  def app
    Server.new
  end

  describe 'POST /join' do
    it 'returns a response matching the join schema' do
      post '/join', { 'name' => 'Bot' }.to_json,
        { 'HTTP_ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json' }
      expect(last_response).to be_ok
      expect(last_response).to match_json_schema('join')
    end
  end


  describe 'GET /game' do
    before do
      post '/join', { 'name' => 'Bot' }.to_json, { 'HTTP_ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json' }
    end

    it 'only allows authorized requests' do
      key = JSON.parse(last_response.body)['api_key']
      encoded = Base64.encode64("#{key}:X").strip
      get '/game', nil, { "HTTP_ACCEPT" => "application/json", "CONTENT_TYPE" => "application/json", "HTTP_AUTHORIZATION" => "Basic #{encoded}" }
      expect(last_response).to be_ok

      get '/game', nil, { "HTTP_ACCEPT" => "application/json", "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq 401

      invalid_encoded = Base64.encode64("invalid:X").strip
      get '/game', nil, { "HTTP_ACCEPT" => "application/json", "CONTENT_TYPE" => "application/json", "HTTP_AUTHORIZATION" => "Basic #{invalid_encoded}" }
      expect(last_response.status).to eq 401
    end

    it 'returns a response matching game schema' do
      key = JSON.parse(last_response.body)['api_key']
      encoded = Base64.encode64("#{key}:X").strip
      get '/game', nil, { "HTTP_ACCEPT" => "application/json", "CONTENT_TYPE" => "application/json", "HTTP_AUTHORIZATION" => "Basic #{encoded}" }
      expect(last_response).to match_json_schema('game')
    end
  end
end
