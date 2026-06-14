class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @subjects = current_user.subjects.includes(:questions).order(created_at: :desc).limit(3)
    @recent_exams = current_user.exams.includes(:subject).finished.order(updated_at: :desc).limit(5)
  end
end
