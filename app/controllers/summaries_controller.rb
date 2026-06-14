class SummariesController < ApplicationController
  before_action :authenticate_user!

  def new
    @summary = current_user.summaries.new
  end

  def create
    @summary = current_user.summaries.new(summary_params)

    if @summary.save
      GenerateQuestionsJob.perform_later(@summary.id)
      redirect_to summary_path(@summary), notice: 'Summary was successfully submitted.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @summary = current_user.summaries.find(params[:id])
  end

  private

  def summary_params
    params.require(:summary).permit(:subject_id, :content, :questions_requested)
  end
end
