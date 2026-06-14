require 'rails_helper'

RSpec.describe 'Summaries', type: :request do
  let(:user) { create(:user) }
  let(:subject_model) { Subject.create!(name: 'Math', user: user) }

  before do
    sign_in user
  end

  describe 'GET /summaries/new' do
    it 'returns http success' do
      get new_summary_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /summaries' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          summary: {
            subject_id: subject_model.id,
            content: 'This is a summary content to test generation.',
            questions_requested: 10
          }
        }
      end

      it 'creates a new Summary' do
        expect {
          post summaries_path, params: valid_params
        }.to change(Summary, :count).by(1)
      end

      it 'redirects to the created summary processing view' do
        post summaries_path, params: valid_params
        expect(response).to redirect_to(summary_path(Summary.last))
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          summary: {
            subject_id: subject_model.id,
            content: '',
            questions_requested: 10
          }
        }
      end

      it 'does not create a new Summary' do
        expect {
          post summaries_path, params: invalid_params
        }.to change(Summary, :count).by(0)
      end

      it 'returns a 422 Unprocessable Entity status' do
        post summaries_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
