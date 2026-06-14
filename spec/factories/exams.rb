FactoryBot.define do
  factory :exam do
    user { nil }
    subject { nil }
    questions_count { 1 }
    correct_count { 1 }
    status { 0 }
  end
end
