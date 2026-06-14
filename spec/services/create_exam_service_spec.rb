require 'rails_helper'

RSpec.describe CreateExamService do
  let(:user) { create(:user) }
  let(:subject) { create(:subject, user: user) }

  describe '.call' do
    context 'when subject has not enough questions' do
      it 'returns a failed result' do
        result = described_class.call(user: user, subject_id: subject.id, questions_count: 5)
        expect(result.success?).to be false
        expect(result.error_message).to include("Não há questões suficientes")
      end
    end

    context 'when subject has enough questions' do
      before do
        create_list(:question, 5, subject: subject)
      end

      it 'creates an exam with the requested number of questions' do
        result = described_class.call(user: user, subject_id: subject.id, questions_count: 3)
        expect(result.success?).to be true
        expect(result.exam).to be_persisted
        expect(result.exam.exam_questions.count).to eq(3)
        expect(result.exam.status).to eq("in_progress")
      end
    end
  end
end
