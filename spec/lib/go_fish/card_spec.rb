require_relative '../../../lib/go_fish/card'

describe 'Card' do
  it 'has a rank and suit' do
    card = Card.new('A', 'Spades')
    expect(card.rank).to eq 'A'
    expect(card.suit).to eq 'Spades'
  end

  it 'should allow valid ranks' do
    expect {
      Card.new('15', 'Spades')
  }.to raise_error Card::InvalidRank
  end

  it 'should allow valid suits' do
    expect {
      Card.new('10', 'Minecraft')
  }.to raise_error Card::InvalidSuit
  end

  describe '#value' do
    it 'returns the index of the given rank' do
      card = Card.new('4', 'Spades')
      expect(card.value).to be 2
    end
  end

  describe '#to_s' do
    let(:card) { Card.new('J', 'Diamonds') }
    let(:readable_card) { 'Jack of Diamonds' }

    it 'returns a readable card string' do
      expect(card.to_s).to eq readable_card
    end
  end
end
