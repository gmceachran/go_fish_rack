require_relative '../controller'

describe Controller, type: :request do
  include Rack::Test::Methods

  def app
    Controller.new
  end

  describe 'POST /join' do
    it 'returns a response matching the join schema' do
      post '/join', { 'name' => 'Bot_Steve' }.to_json,
        { 'HTTP_ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json' }
      expect(last_response).to be_ok
      expect(last_response).to match_json_schema('join')
    end
  end


  describe 'GET /game' do
    before do
      post '/join', { 'name' => 'Bot_Steve' }.to_json, { 'HTTP_ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json' }
      Controller.game.turn_results << TurnResult.new(cards: [Card.new('A', 'Spades')])
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

  describe 'POST /game' do
    let(:player_name) { 'John' }
    let(:bot_name) { 'Bot_Steve' }
    let(:rank) { 'Q' }

    before do
      post '/join', { 'name' => bot_name }.to_json, { 'HTTP_ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json' }
      key = JSON.parse(last_response.body)['api_key']
      join_game(player_name)
      Controller.game.players.first.hand = [Card.new('Q', 'Spades')]
      encoded = Base64.encode64("#{key}:X").strip
      post '/game', { 'rank' => rank, 'player' => player_name }.to_json, { "HTTP_ACCEPT" => "application/json", "CONTENT_TYPE" => "application/json", "HTTP_AUTHORIZATION" => "Basic #{encoded}" }
    end

    it "plays turn with bot's choice" do
      body = JSON.parse(last_response.body)
      expect(body['turn_index']).to eq 1
    end
  end

  def join_game(name)
    visit '/'
    fill_in :name, with: name
    click_on 'Join'
  end

  def perform_turn(opponent_name)
    find('option', text: opponent_name, match: :first).select_option
    select 'A', from: 'rank'
    click_on 'Ask for Cards'
  end
end
