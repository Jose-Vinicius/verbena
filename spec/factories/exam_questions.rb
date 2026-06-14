FactoryBot.define do
  factory :exam_question do
    exam { nil }
    question { nil }
    chosen_index { 1 }
    is_correct { false }
  end
end
