Rails.application.routes.draw do
  get "dashboard/index"
  devise_for :users

  resources :summaries, only: [ :new, :create, :show ]
  resources :subjects, only: [ :index, :new, :create ]
  resources :questions, only: [ :index, :edit, :update, :destroy ]
  resources :exams, only: [ :new, :create, :show ]
  resources :exam_questions, only: [ :show, :update ]
  resources :group_quizzes, only: [ :new, :create, :show, :update ] do
    get :participants, on: :member
  end

  # Área pública — participantes do quiz em grupo
  scope "/quiz" do
    get ":token", to: "public_quiz#show", as: :public_quiz
    post ":token/join", to: "public_quiz#join", as: :join_public_quiz
    get ":token/q/:position", to: "public_quiz#question", as: :public_quiz_question
    patch ":token/q/:position", to: "public_quiz#answer", as: :answer_public_quiz_question
    post ":token/finish", to: "public_quiz#finish", as: :public_quiz_finish
    get ":token/waiting", to: "public_quiz#waiting", as: :public_quiz_waiting
    get ":token/result", to: "public_quiz#result", as: :public_quiz_result
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "dashboard#index"
end
