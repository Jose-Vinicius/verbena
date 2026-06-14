require 'rails_helper'

RSpec.describe Question, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:summary) }
    it { is_expected.to belong_to(:subject) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:statement) }
    it { is_expected.to validate_presence_of(:correct_index) }
    it { is_expected.to validate_numericality_of(:correct_index).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(4) }

    it 'validates options is an array of 4 or 5 items' do
      question = build(:question, options: [ "A", "B", "C", "D" ])
      expect(question).to be_valid

      question.options = [ "A", "B", "C" ]
      expect(question).not_to be_valid
      expect(question.errors[:options]).to include("must be an array of 4 or 5 items")

      question.options = [ "A", "B", "C", "D", "E", "F" ]
      expect(question).not_to be_valid
      expect(question.errors[:options]).to include("must be an array of 4 or 5 items")

      question.options = "not an array"
      expect(question).not_to be_valid
    end
  end

  describe 'scopes' do
    describe '.by_subject' do
      it 'returns questions for a specific subject' do
        subject1 = create(:subject)
        subject2 = create(:subject)
        q1 = create(:question, subject: subject1)
        q2 = create(:question, subject: subject2)

        expect(described_class.by_subject(subject1.id)).to include(q1)
        expect(described_class.by_subject(subject1.id)).not_to include(q2)
      end
    end
  end
end
