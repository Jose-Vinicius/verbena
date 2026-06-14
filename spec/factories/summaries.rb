FactoryBot.define do
  factory :summary do
    association :user
    association :subject
    content { "MyText" }
    questions_requested { 10 }
    status { :pending }
  end
end
