class PublicQuizController < ApplicationController
  layout "public_quiz"

  before_action :set_group_quiz
  before_action :check_accessibility, only: [:join]
  before_action :set_participant, only: [:question, :answer, :finish, :result, :waiting]

  def show
    if @group_quiz.expired? || @group_quiz.closed?
      render :expired and return
    end

    existing = find_participant_from_cookie
    if existing
      redirect_to_next_question(existing)
    end
  end

  def join
    if @group_quiz.expired? || @group_quiz.closed?
      redirect_to public_quiz_path(@group_quiz.token), alert: "Esta sala não está mais disponível." and return
    end

    name = params[:name].to_s.strip
    if name.blank?
      redirect_to public_quiz_path(@group_quiz.token), alert: "Por favor, informe seu nome." and return
    end

    participant = @group_quiz.group_participants.create!(name: name)
    cookies.signed[:participant_token] = { value: participant.token, httponly: true }

    redirect_to public_quiz_question_path(@group_quiz.token, 1)
  end

  def question
    @quiz_question = @group_quiz.group_quiz_questions.find_by(position: params[:position])
    unless @quiz_question
      finish_and_redirect
      return
    end

    @question = @quiz_question.question
    @position = @quiz_question.position
    @total = @group_quiz.questions_count
    @existing_answer = @participant.group_answers.find_by(question_id: @question.id)
  end

  def answer
    @quiz_question = @group_quiz.group_quiz_questions.find_by!(position: params[:position])
    question = @quiz_question.question

    existing = @participant.group_answers.find_by(question_id: question.id)
    if existing
      redirect_to next_question_path(@quiz_question.position) and return
    end

    chosen = params[:chosen_index].to_i
    is_correct = (chosen == question.correct_index)

    @participant.group_answers.create!(
      question: question,
      chosen_index: chosen,
      is_correct: is_correct
    )

    redirect_to public_quiz_question_path(@group_quiz.token, @quiz_question.position)
  end

  def finish
    FinishGroupParticipantService.call(participant: @participant) unless @participant.finished?

    all_finished = @group_quiz.group_participants.where(status: :in_progress).none?
    if all_finished
      redirect_to public_quiz_result_path(@group_quiz.token)
    else
      redirect_to public_quiz_waiting_path(@group_quiz.token)
    end
  end

  def waiting
    all_finished = @group_quiz.group_participants.where(status: :in_progress).none?
    if all_finished
      redirect_to public_quiz_result_path(@group_quiz.token) and return
    end

    @total_participants = @group_quiz.group_participants.count
    @finished_count = @group_quiz.group_participants.where(status: :finished).count
  end

  def result
    unless @participant.finished?
      redirect_to public_quiz_path(@group_quiz.token) and return
    end

    all_finished = @group_quiz.group_participants.where(status: :in_progress).none?
    unless all_finished
      redirect_to public_quiz_waiting_path(@group_quiz.token) and return
    end

    @participants = @group_quiz.group_participants.where(status: :finished).order(correct_count: :desc, updated_at: :asc)
    @answers = @participant.group_answers.includes(:question)
  end

  private

  def set_group_quiz
    @group_quiz = GroupQuiz.find_by!(token: params[:token])
  rescue ActiveRecord::RecordNotFound
    render plain: "Sala não encontrada", status: :not_found
  end

  def check_accessibility
    if @group_quiz.expired? || @group_quiz.closed?
      redirect_to public_quiz_path(@group_quiz.token) and return
    end
  end

  def set_participant
    @participant = find_participant_from_cookie
    unless @participant
      redirect_to public_quiz_path(@group_quiz.token), alert: "Você precisa entrar na sala primeiro." and return
    end
  end

  def find_participant_from_cookie
    token = cookies.signed[:participant_token]
    return nil unless token
    @group_quiz.group_participants.find_by(token: token)
  end

  def redirect_to_next_question(participant)
    answered_ids = participant.group_answers.pluck(:question_id)
    next_qq = @group_quiz.group_quiz_questions.where.not(question_id: answered_ids).order(:position).first

    if next_qq
      redirect_to public_quiz_question_path(@group_quiz.token, next_qq.position)
    elsif participant.in_progress?
      redirect_to public_quiz_finish_path(@group_quiz.token), status: :see_other
    elsif @group_quiz.group_participants.where(status: :in_progress).any?
      redirect_to public_quiz_waiting_path(@group_quiz.token)
    else
      redirect_to public_quiz_result_path(@group_quiz.token)
    end
  end

  def next_question_path(current_position)
    next_qq = @group_quiz.group_quiz_questions.where("position > ?", current_position).order(:position).first
    if next_qq
      public_quiz_question_path(@group_quiz.token, next_qq.position)
    else
      public_quiz_finish_path(@group_quiz.token)
    end
  end

  def finish_and_redirect
    FinishGroupParticipantService.call(participant: @participant) unless @participant.finished?

    if @group_quiz.group_participants.where(status: :in_progress).any?
      redirect_to public_quiz_waiting_path(@group_quiz.token)
    else
      redirect_to public_quiz_result_path(@group_quiz.token)
    end
  end
end
