require_relative '../../../lib/go_fish/book'

describe Book do
  describe '#value' do
    it 'returns the index of the given rank' do
      book = Book.new('4')
      expect(book.value).to be 2
    end
  end
end
