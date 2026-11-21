require 'rails_helper'

RSpec.describe 'Subject', type: :model do
  let(:user) { create(:user) }

  it 'is valid with valid attributes' do
    subject = Subject.new(name: 'Math', user: user)
    expect(subject).to be_valid
  end

  it 'is not valid without a name' do
    subject = Subject.new(name: nil, user: user)
    expect(subject).not_to be_valid
  end

  it 'is not valid without a user' do
    subject = Subject.new(name: 'Math', user: nil)
    expect(subject).not_to be_valid
  end

  describe '#soft_delete!' do
    it 'sets deleted_at on the subject and cascades to active questions and summaries' do
      subject = create(:subject, user: user)
      summary = create(:summary, user: user, subject: subject)
      active_question = create(:question, subject: subject, summary: summary)
      already_deleted_at = 2.days.ago
      deleted_question = create(:question, subject: subject, summary: summary, deleted_at: already_deleted_at)

      subject.soft_delete!

      expect(subject.reload).to be_deleted
      expect(active_question.reload).to be_deleted
      expect(summary.reload).to be_deleted
      expect(deleted_question.reload.deleted_at).to be_within(1.second).of(already_deleted_at)
      expect(Subject.active).not_to include(subject)
      expect(Question.active).not_to include(active_question)
    end
  end
end
