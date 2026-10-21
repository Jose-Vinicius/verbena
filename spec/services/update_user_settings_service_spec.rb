require 'rails_helper'

RSpec.describe UpdateUserSettingsService do
  let(:user) { create(:user) }

  describe '.call' do
    it 'updates gemini_model and custom_prompt successfully' do
      result = described_class.call(
        user: user,
        gemini_model: 'gemini-2.0-flash',
        custom_prompt: 'Novo prompt customizado para estudos'
      )

      expect(result.success?).to be true
      expect(user.reload.gemini_model).to eq('gemini-2.0-flash')
      expect(user.custom_prompt).to eq('Novo prompt customizado para estudos')
    end

    it 'clears custom_prompt when restore_default is true' do
      user.update!(custom_prompt: 'Prompt personalizado')

      result = described_class.call(
        user: user,
        gemini_model: user.gemini_model,
        custom_prompt: 'Ignorado',
        restore_default: true
      )

      expect(result.success?).to be true
      expect(user.reload.custom_prompt).to be_nil
    end

    it 'sets custom_prompt to nil when prompt equals default prompt' do
      result = described_class.call(
        user: user,
        gemini_model: 'gemini-2.5-flash',
        custom_prompt: GeminiClient.default_prompt
      )

      expect(result.success?).to be true
      expect(user.reload.custom_prompt).to be_nil
    end

    it 'fails when gemini_model is not in the allowed list' do
      result = described_class.call(
        user: user,
        gemini_model: 'invalid-model-name',
        custom_prompt: nil
      )

      expect(result.success?).to be false
      expect(result.errors).to be_present
    end
  end
end
