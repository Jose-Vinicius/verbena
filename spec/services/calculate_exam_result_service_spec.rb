require 'rails_helper'

RSpec.describe CalculateExamResultService do
  let(:user) { create(:user) }
  let(:subject) { create(:subject, user: user) }
  let(:exam) { create(:exam, user: user, subject: subject, questions_count: 3, correct_count: 0) }

  before do
    q1 = create(:question, subject: subject)
    q2 = create(:question, subject: subject)
    q3 = create(:question, subject: subject)
    
    create(:exam_question, exam: exam, question: q1, is_correct: true)
    create(:exam_question, exam: exam, question: q2, is_correct: false)
    create(:exam_question, exam: exam, question: q3, is_correct: true)
  end

  describe '.call' do
    it 'calculates correct answers and marks exam as finished' do
      result = described_class.call(exam: exam)
      
      expect(result.success?).to eq(true), result.error_message
      expect(exam.reload.correct_count).to eq(2)
      expect(exam.status).to eq('finished')
    end
  end
end
