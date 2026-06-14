require 'rails_helper'

RSpec.describe Exam, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:subject) }
    it { is_expected.to have_many(:exam_questions).dependent(:destroy) }
    it { is_expected.to have_many(:questions).through(:exam_questions) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:questions_count) }
    it { is_expected.to validate_numericality_of(:questions_count).is_greater_than(0) }
    it { is_expected.to validate_presence_of(:correct_count) }
    it { is_expected.to validate_numericality_of(:correct_count).is_greater_than_or_equal_to(0) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(in_progress: 0, finished: 1) }
  end
end
