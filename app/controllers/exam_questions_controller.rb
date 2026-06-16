class ExamQuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_exam_question, only: [:show, :update]

  def show
    # Render the exam interface
    @exam = @exam_question.exam
    @all_questions = @exam.exam_questions.order(:id)
    @current_index = @all_questions.index(@exam_question) + 1
    @total_questions = @exam.questions_count
    
    # Find next question
    @next_question = @all_questions[@current_index]
  end

  def update
    # Only update if it hasn't been answered yet
    if @exam_question.chosen_index.nil?
      chosen = params[:chosen_index].to_i
      is_correct = (chosen == @exam_question.question.correct_index)
      
      @exam_question.update(
        chosen_index: chosen,
        is_correct: is_correct
      )
    end

    redirect_to exam_question_path(@exam_question)
  end

  private

  def set_exam_question
    @exam_question = ExamQuestion.joins(:exam).where(exams: { user_id: current_user.id }).find(params[:id])
  end
end
