require 'rails_helper'

RSpec.describe 'Root path', type: :request do
  describe 'GET /' do
    context 'when not authenticated' do
      it 'redirects to the login page' do
        get root_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when authenticated' do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it 'returns a successful response' do
        get root_path
        expect(response).to have_http_status(:success)
      end
    end
  end
end
