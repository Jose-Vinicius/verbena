require 'rails_helper'

RSpec.describe 'Settings', type: :request do
  let(:user) { create(:user) }

  describe 'GET /settings' do
    context 'when user is not logged in' do
      it 'redirects to login page' do
        get settings_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is logged in' do
      before { sign_in user }

      it 'returns http success and renders settings' do
        get settings_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include('Configurações de IA')
        expect(response.body).to include('Modelo Default do Gemini')
        expect(response.body).to include('Prompt de Geração de Questões')
      end
    end
  end

  describe 'PATCH /settings' do
    before { sign_in user }

    context 'with valid parameters' do
      it 'updates user preferences and redirects with notice' do
        patch settings_path, params: {
          user: {
            gemini_model: 'gemini-3.8-flash',
            custom_prompt: 'Instruções personalizadas de teste'
          }
        }

        expect(response).to redirect_to(settings_path)
        follow_redirect!
        expect(response.body).to include('Configurações atualizadas com sucesso.')
        expect(user.reload.gemini_model).to eq('gemini-3.8-flash')
        expect(user.custom_prompt).to eq('Instruções personalizadas de teste')
      end
    end

    context 'with invalid parameters' do
      it 'returns unprocessable entity and shows errors' do
        patch settings_path, params: {
          user: {
            gemini_model: 'invalid-model-name',
            custom_prompt: 'Algum prompt'
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('não está incluído na lista')
      end
    end
  end

  describe 'POST /settings/restore_default_prompt' do
    before do
      user.update!(custom_prompt: 'Prompt customizado antigo')
      sign_in user
    end

    it 'resets custom_prompt to nil and redirects with notice' do
      post restore_default_prompt_settings_path
      expect(response).to redirect_to(settings_path)
      follow_redirect!
      expect(response.body).to include('Prompt padrão restaurado com sucesso.')
      expect(user.reload.custom_prompt).to be_nil
    end
  end
end
