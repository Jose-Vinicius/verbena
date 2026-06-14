require 'rails_helper'

RSpec.describe 'GenerateQuestionsJob', type: :job do
  let(:user) { create(:user) }
  let(:subject_model) { create(:subject, user: user) }
  let(:summary) { create(:summary, user: user, subject: subject_model, status: :pending) }

  it 'enqueues the job' do
    expect {
      GenerateQuestionsJob.perform_later(summary.id)
    }.to have_enqueued_job(GenerateQuestionsJob).with(summary.id)
  end

  it 'calls the GenerateQuestionsService' do
    expect(GenerateQuestionsService).to receive(:call).with(summary)

    GenerateQuestionsJob.perform_now(summary.id)
  end
end
