require 'rails_helper'

RSpec.describe 'Summary', type: :model do
  let(:user) { create(:user) }
  let(:subject_model) { Subject.create!(name: 'Math', user: user) }

  it 'is valid with valid attributes' do
    summary = Summary.new(
      user: user,
      subject: subject_model,
      content: 'A' * 100,
      questions_requested: 10,
      status: :pending
    )
    expect(summary).to be_valid
  end

  it 'is not valid without content' do
    summary = Summary.new(user: user, subject: subject_model, content: nil, questions_requested: 10)
    expect(summary).not_to be_valid
  end

  it 'is not valid with content over 10000 characters' do
    summary = Summary.new(user: user, subject: subject_model, content: 'A' * 10001, questions_requested: 10)
    expect(summary).not_to be_valid
  end

  it 'is not valid without questions_requested' do
    summary = Summary.new(user: user, subject: subject_model, content: 'Content', questions_requested: nil)
    expect(summary).not_to be_valid
  end

  it 'is not valid if questions_requested is not 10, 20, or 30' do
    summary = Summary.new(user: user, subject: subject_model, content: 'Content', questions_requested: 15)
    expect(summary).not_to be_valid
  end

  it 'defaults status to pending' do
    summary = Summary.new(user: user, subject: subject_model, content: 'Content', questions_requested: 10)
    expect(summary.status).to eq('pending')
  end

  describe 'scopes' do
    before do
      Summary.create!(user: user, subject: subject_model, content: 'A', questions_requested: 10, status: :pending)
      Summary.create!(user: user, subject: subject_model, content: 'B', questions_requested: 20, status: :processing)
      Summary.create!(user: user, subject: subject_model, content: 'C', questions_requested: 30, status: :done)
    end

    it '.pending returns only pending summaries' do
      expect(Summary.pending.count).to eq(1)
      expect(Summary.pending.first.content).to eq('A')
    end

    it '.processing returns only processing summaries' do
      expect(Summary.processing.count).to eq(1)
      expect(Summary.processing.first.content).to eq('B')
    end
  end
end
