class HistoryController < ApplicationController
  before_action :authenticate_user!

  def index
    exams = current_user.exams.includes(:subject).finished.order(updated_at: :desc)
    group_quizzes = current_user.group_quizzes.includes(:subject).order(updated_at: :desc)
    
    @activities = (exams.to_a + group_quizzes.to_a).sort_by(&:updated_at).reverse
  end
end
