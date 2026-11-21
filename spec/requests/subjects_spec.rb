require 'rails_helper'

RSpec.describe "Subjects", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "GET /subjects" do
    it "lists only active subjects" do
      active_subject = create(:subject, user: user, name: "Biologia")
      deleted_subject = create(:subject, user: user, name: "Química", deleted_at: Time.current)

      get subjects_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Biologia")
      expect(response.body).not_to include("Química")
    end
  end

  describe "DELETE /subjects/:id" do
    it "soft deletes the subject and its linked questions" do
      subject = create(:subject, user: user, name: "História")
      summary = create(:summary, user: user, subject: subject)
      question = create(:question, subject: subject, summary: summary)

      delete subject_path(subject)

      expect(response).to redirect_to(subjects_path)
      expect(subject.reload).to be_deleted
      expect(question.reload).to be_deleted
      expect(summary.reload).to be_deleted
    end
  end
end
