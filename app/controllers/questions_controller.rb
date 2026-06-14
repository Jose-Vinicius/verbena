class QuestionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @questions = current_user.questions.includes(:subject)

    if params[:subject_id].present?
      @questions = @questions.where(subject_id: params[:subject_id])
    end

    if params[:query].present?
      @questions = @questions.where("statement ILIKE :q OR explanation ILIKE :q", q: "%#{params[:query]}%")
    end

    @grouped_questions = @questions.group_by(&:subject)
  end
end
