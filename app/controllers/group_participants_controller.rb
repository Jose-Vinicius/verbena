class GroupParticipantsController < ApplicationController
  before_action :authenticate_user!

  def show
    @participant = GroupParticipant.kept.joins(:group_quiz).where(group_quizzes: { user_id: current_user.id, deleted_at: nil }).find(params[:id])
    @group_quiz = @participant.group_quiz
    @answers = @participant.group_answers.kept.includes(:question).order("group_answers.id ASC")
  end

  def destroy
    # Garante que o participante pertence a um quiz ativo do usuário atual
    @group_quiz = current_user.group_quizzes.kept.joins(:group_participants).where(group_participants: { id: params[:id], deleted_at: nil }).first!
    @participant = @group_quiz.group_participants.kept.find(params[:id])

    @participant.soft_delete!

    # Como a tela usa polling, não precisamos redirecionar com aviso, apenas retornamos sucesso.
    # Mas para garantir compatibilidade caso clicado sem JS, redirecionamos.
    redirect_to group_quiz_path(@group_quiz), notice: "Participante removido da sala."
  end
end
