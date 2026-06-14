class ExamsController < ApplicationController
  before_action :authenticate_user!

  def new
    @subjects = current_user.subjects.includes(:questions)
  end

  def create
    result = CreateExamService.call(
      user: current_user,
      subject_id: params[:subject_id],
      questions_count: params[:questions_count]
    )

    if result.success?
      first_question = result.exam.exam_questions.order(:id).first
      redirect_to exam_question_path(first_question)
    else
      redirect_to new_exam_path, alert: result.error_message
    end
  end

  def show
    @exam = current_user.exams.find(params[:id])
    
    # If finishing the exam here
    if @exam.in_progress?
      CalculateExamResultService.call(exam: @exam)
      @exam.reload
    end
  end
end
