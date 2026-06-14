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
end
