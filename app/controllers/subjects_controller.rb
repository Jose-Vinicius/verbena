class SubjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_subject, only: %i[show edit update destroy]

  def index
    @subjects = current_user.subjects.active.includes(:questions, :study_sources).order(created_at: :desc)
  end

  def show
    @study_sources = @subject.study_sources.active.order(created_at: :desc)
    @summary = current_user.summaries.new(subject: @subject)
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
    @subject.soft_delete!
    redirect_to subjects_path, notice: "Matéria e suas questões foram inativadas com sucesso."
  end

  private

  def set_subject
    @subject = current_user.subjects.active.find(params[:id])
  end

  def subject_params
    params.require(:subject).permit(:name, :color, :icon)
  end
end
