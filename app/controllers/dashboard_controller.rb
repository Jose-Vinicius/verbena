class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @subjects = current_user.subjects.includes(:questions).order(created_at: :desc).limit(3)
    
    exams = current_user.exams.includes(:subject).finished.order(updated_at: :desc).limit(3)
    group_quizzes = current_user.group_quizzes.includes(:subject).order(updated_at: :desc).limit(3)
    
    @recent_activities = (exams.to_a + group_quizzes.to_a).sort_by(&:updated_at).reverse.first(3)
  end
end
