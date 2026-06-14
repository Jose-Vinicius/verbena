class SubjectsController < ApplicationController
  before_action :authenticate_user!

  def index
    @subjects = current_user.subjects.order(created_at: :desc)
  end

  def new
    @subject = current_user.subjects.new
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

  private

  def subject_params
    params.require(:subject).permit(:name)
  end
end
