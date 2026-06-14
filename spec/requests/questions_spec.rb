require 'rails_helper'

RSpec.describe "Questions", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "GET /index" do
    it "returns http success" do
      get questions_path
      expect(response).to have_http_status(:success)
    end

    it "renders the subjects" do
      subject1 = create(:subject, user: user, name: "Math")
      subject2 = create(:subject, user: user, name: "Science")
      q1 = create(:question, subject: subject1)
      q2 = create(:question, subject: subject2)

      get questions_path

      expect(response.body).to include("Math")
      expect(response.body).to include("Science")
    end
  end
end
