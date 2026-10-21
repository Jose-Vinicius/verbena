require 'rails_helper'

RSpec.describe 'GenerateQuestionsService' do
  let(:user) { create(:user, gemini_model: 'gemini-2.0-flash', custom_prompt: 'Custom test prompt') }
  let(:subject_model) { create(:subject, user: user) }
  let(:summary) { create(:summary, user: user, subject: subject_model, status: :pending) }

  describe '#call' do
    it 'updates the summary status to done and creates questions using user preferences' do
      expect(GeminiClient).to receive(:generate_questions).with(
        prompt: 'Custom test prompt',
        content: summary.content,
        count: summary.questions_requested,
        default_model: 'gemini-2.0-flash'
      ).and_return([
        {
          "statement" => "Which of the following is true?",
          "options" => [ "A", "B", "C", "D" ],
          "correct_index" => 0,
          "explanation" => "Because A is correct."
        }
      ])

      expect(summary.status).to eq('pending')

      expect {
        GenerateQuestionsService.call(summary)
      }.to change(Question, :count).by(1)

      expect(summary.reload.status).to eq('done')
    end

    it 'updates the status to error if something fails' do
      allow(GeminiClient).to receive(:generate_questions).and_raise(StandardError, 'API Error')

      expect {
        GenerateQuestionsService.call(summary)
      }.not_to raise_error

      expect(summary.reload.status).to eq('error')
    end
  end
end
