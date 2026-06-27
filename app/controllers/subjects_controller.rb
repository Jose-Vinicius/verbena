class SubjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_subject, only: %i[edit update destroy]

  def index
    @subjects = current_user.subjects.order(created_at: :desc)
  end

  def new
    @subject = current_user.subjects.new
  end

  def edit
  end

  def create
    @subject = current_user.subjects.new(subject_params)

    if @subject.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to new_summary_path, notice: "Matéria criada com sucesso." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @subject.update(subject_params)
      redirect_to subjects_path, notice: "Matéria atualizada com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @subject.destroy
    redirect_to subjects_path, notice: "Matéria excluída com sucesso."
  end

  private

  def set_subject
    @subject = current_user.subjects.find(params[:id])
  end

  def subject_params
    params.require(:subject).permit(:name, :color, :icon)
  end
end
