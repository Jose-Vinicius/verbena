class GroupQuizzesController < ApplicationController
  before_action :authenticate_user!

  def new
    @subjects = current_user.subjects.includes(:questions)
  end

  def create
    result = CreateGroupQuizService.call(
      user: current_user,
      subject_id: params[:subject_id],
      questions_count: params[:questions_count],
      title: params[:title]
    )

    if result.success?
      redirect_to group_quiz_path(result.group_quiz)
    else
      redirect_to new_group_quiz_path, alert: result.error_message
    end
  end

  def show
    @group_quiz = current_user.group_quizzes.find(params[:id])
    @participants = @group_quiz.group_participants.order(correct_count: :desc, updated_at: :asc)
  end

  def participants
    @group_quiz = current_user.group_quizzes.find(params[:id])
    @participants = @group_quiz.group_participants.order(correct_count: :desc, updated_at: :asc)
    render partial: "participants", locals: { group_quiz: @group_quiz, participants: @participants }, layout: false
  end

  def update
    @group_quiz = current_user.group_quizzes.find(params[:id])
    @group_quiz.update!(status: :closed)
    redirect_to group_quiz_path(@group_quiz), notice: "Sala encerrada."
  end
end
