require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'is invalid without an email' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("não pode ficar em branco")
    end

    it 'is invalid with a duplicate email' do
      create(:user, email: 'test@example.com')
      user = build(:user, email: 'test@example.com')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('já está em uso')
    end

    it 'is invalid without a password' do
      user = build(:user, password: nil)
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("não pode ficar em branco")
    end

    it 'is invalid with an unknown gemini_model' do
      user = build(:user, gemini_model: 'unknown-model')
      expect(user).not_to be_valid
      expect(user.errors[:gemini_model]).to be_present
    end

    it 'is valid with Gemini 3 models' do
      expect(build(:user, gemini_model: 'gemini-3.8-flash')).to be_valid
      expect(build(:user, gemini_model: 'gemini-3.5-flash')).to be_valid
      expect(build(:user, gemini_model: 'gemini-3-flash')).to be_valid
    end
  end

  describe '#effective_gemini_model' do
    it 'returns the user choice when present' do
      user = build(:user, gemini_model: 'gemini-1.5-pro')
      expect(user.effective_gemini_model).to eq('gemini-1.5-pro')
    end

    it 'returns the default model when nil or empty' do
      user = build(:user, gemini_model: nil)
      expect(user.effective_gemini_model).to eq(GeminiClient::DEFAULT_MODEL)
    end
  end

  describe '#effective_prompt' do
    it 'returns custom_prompt when set' do
      user = build(:user, custom_prompt: 'Instruções personalizadas')
      expect(user.effective_prompt).to eq('Instruções personalizadas')
    end

    it 'falls back to GeminiClient.default_prompt when blank' do
      user = build(:user, custom_prompt: nil)
      expect(user.effective_prompt).to eq(GeminiClient.default_prompt)
    end
  end
end
