require 'rails_helper'

RSpec.describe 'GenerateQuestionsService' do
  let(:user) { create(:user) }
  let(:subject_model) { create(:subject, user: user) }
  let(:summary) { create(:summary, user: user, subject: subject_model, status: :pending) }

  describe '#call' do
    it 'updates the summary status to processing, then done' do
      # We can mock the sleep/processing time so the test runs fast
      allow_any_instance_of(GenerateQuestionsService).to receive(:sleep)

      expect(summary.status).to eq('pending')

      GenerateQuestionsService.call(summary)

      expect(summary.reload.status).to eq('done')
    end

    # In a real scenario, we might test what happens if an error occurs
    it 'updates the status to error if something fails' do
      allow_any_instance_of(GenerateQuestionsService).to receive(:sleep).and_raise(StandardError, 'API Error')

      expect {
        GenerateQuestionsService.call(summary)
      }.not_to raise_error

      expect(summary.reload.status).to eq('error')
    end
  end
end
