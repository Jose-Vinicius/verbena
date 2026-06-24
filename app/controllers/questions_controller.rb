class QuestionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @questions = current_user.questions.active.includes(:subject)

    if params[:subject_id].present?
      @questions = @questions.where(subject_id: params[:subject_id])
    end

    if params[:query].present?
      @questions = @questions.where("statement ILIKE :q OR explanation ILIKE :q", q: "%#{params[:query]}%")
    end

    @questions = @questions.order(:id)
    @grouped_questions = @questions.group_by(&:subject)
  end

  def edit
    @question = current_user.questions.active.find(params[:id])
  end

  def update
    @question = current_user.questions.active.find(params[:id])
    
    q_params = params.require(:question).permit(:statement, :explanation, :correct_index, options: [])
    options = q_params[:options] || []
    
    if options.size == @question.options.size
      @question.statement = q_params[:statement]
      @question.explanation = q_params[:explanation]
      @question.correct_index = q_params[:correct_index]
      @question.options = options
      
      if @question.save
        redirect_to questions_path, notice: "Questão atualizada com sucesso."
      else
        render :edit, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "Não é permitido alterar a quantidade de alternativas."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @question = current_user.questions.active.find(params[:id])
    @question.soft_delete!
    redirect_to questions_path, notice: "Questão excluída com sucesso."
  end
end
