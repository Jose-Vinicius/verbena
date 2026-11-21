class SummariesController < ApplicationController
  before_action :authenticate_user!

  def new
    @summary = current_user.summaries.new
  end

  def create
    @summary = current_user.summaries.new(summary_params)
    sanitize_study_source_ids!

    if @summary.save
      GenerateQuestionsJob.perform_later(@summary.id)
      redirect_to summary_path(@summary), notice: "Geração iniciada! Acompanhe o progresso abaixo."
    elsif @summary.from_study_sources? || params.dig(:summary, :study_source_ids).present?
      redirect_to subject_path(@summary.subject_id || subjects_path), alert: @summary.errors.full_messages.to_sentence
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @summary = current_user.summaries.kept.find(params[:id])
  end

  private

  def summary_params
    params.require(:summary).permit(:subject_id, :content, :questions_requested, :focus_query, study_source_ids: [])
  end

  def sanitize_study_source_ids!
    raw_ids = Array(params.dig(:summary, :study_source_ids)).reject(&:blank?)
    return if raw_ids.empty?

    valid_ids = current_user.study_sources.active.ready
                            .where(subject_id: @summary.subject_id, id: raw_ids)
                            .pluck(:id)
    @summary.study_source_ids = valid_ids
  end
end
