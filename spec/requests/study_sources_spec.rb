require 'rails_helper'

RSpec.describe "StudySources", type: :request do
  let(:user) { create(:user) }
  let(:subject_record) { create(:subject, user: user, name: "Biologia") }

  before do
    sign_in user
  end

  describe "GET /subjects/:id" do
    it "renders the NotebookLM-style workspace for the subject" do
      create(:study_source, user: user, subject: subject_record, title: "Resumo Celular.pdf", status: :ready)

      get subject_path(subject_record)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Fontes de Estudo")
      expect(response.body).to include("Resumo Celular.pdf")
    end
  end

  describe "POST /subjects/:subject_id/study_sources" do
    it "creates a text source and enqueues ProcessStudySourceJob" do
      expect {
        post subject_study_sources_path(subject_record), params: {
          title: "Minhas Anotações",
          raw_text: "A célula é a unidade básica da vida."
        }
      }.to have_enqueued_job(ProcessStudySourceJob)
       .and change(StudySource, :count).by(1)

      expect(response).to redirect_to(subject_path(subject_record))
    end
  end

  describe "PATCH /study_sources/:id/toggle" do
    it "toggles source selection" do
      source = create(:study_source, user: user, subject: subject_record, selected: true)

      patch toggle_study_source_path(source)

      expect(source.reload.selected).to be(false)
    end
  end

  describe "DELETE /study_sources/:id" do
    it "soft deletes the source and its chunks" do
      source = create(:study_source, user: user, subject: subject_record, status: :ready)
      chunk = create(:source_chunk, study_source: source)

      delete study_source_path(source)

      expect(source.reload).to be_deleted
      expect(chunk.reload).to be_deleted
    end
  end
end
