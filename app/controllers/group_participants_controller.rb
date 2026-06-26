class GroupParticipantsController < ApplicationController
  before_action :authenticate_user!

  def destroy
    # Garante que o participante pertence a um quiz do usuário atual
    @group_quiz = current_user.group_quizzes.joins(:group_participants).where(group_participants: { id: params[:id] }).first!
    @participant = @group_quiz.group_participants.find(params[:id])
    
    @participant.destroy!

    # Como a tela usa polling, não precisamos redirecionar com aviso, apenas retornamos sucesso.
    # Mas para garantir compatibilidade caso clicado sem JS, redirecionamos.
    redirect_to group_quiz_path(@group_quiz), notice: "Participante removido da sala."
  end
end
