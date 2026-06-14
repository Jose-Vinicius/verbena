require 'rails_helper'

RSpec.describe ExamQuestion, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:exam) }
    it { is_expected.to belong_to(:question) }
  end

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:chosen_index).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(4).allow_nil }
  end
end
