class StudySourcesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_subject, only: :create
  before_action :set_study_source, only: %i[toggle destroy]

  def create
    created_sources = build_sources_from_params

    if created_sources.empty?
      redirect_to subject_path(@subject), alert: "Envie pelo menos um arquivo (PDF, PPTX, DOCX, TXT/MD) ou cole um texto."
      return
    end

    created_sources.each do |source|
      ProcessStudySourceJob.perform_later(source.id)
    end

    @study_sources = @subject.study_sources.active.order(created_at: :desc)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to subject_path(@subject), notice: "#{created_sources.size} fonte(s) adicionada(s) para extração." }
    end
  end

  def toggle
    @study_source.update!(selected: !@study_source.selected)
    @subject = @study_source.subject
    @study_sources = @subject.study_sources.active.order(created_at: :desc)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to subject_path(@subject) }
    end
  end

  def destroy
    @subject = @study_source.subject
    @study_source.soft_delete!
    @study_sources = @subject.study_sources.active.order(created_at: :desc)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to subject_path(@subject), notice: "Fonte inativada com sucesso." }
    end
  end

  private

  def set_subject
    @subject = current_user.subjects.active.find(params[:subject_id])
  end

  def set_study_source
    @study_source = current_user.study_sources.active.find(params[:id])
  end

  def build_sources_from_params
    sources = []
    files = Array(params[:files]).reject(&:blank?)

    files.each do |uploaded_file|
      source = @subject.study_sources.create!(
        user: current_user,
        title: uploaded_file.original_filename,
        source_type: StudySource.detect_source_type(uploaded_file.original_filename),
        status: :pending,
        selected: true
      )
      source.file.attach(uploaded_file)
      sources << source
    end

    raw_text = params[:raw_text].to_s.strip
    if raw_text.present?
      title = params[:title].to_s.strip.presence || "Anotação #{Time.current.strftime('%d/%m %H:%M')}"
      source = @subject.study_sources.create!(
        user: current_user,
        title: title,
        source_type: :text,
        raw_text: raw_text,
        status: :pending,
        selected: true
      )
      sources << source
    end

    sources
  end
end
