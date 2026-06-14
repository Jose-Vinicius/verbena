FactoryBot.define do
  factory :question do
    summary
    subject
    statement { "What is the capital of France?" }
    options { [ "London", "Berlin", "Paris", "Madrid" ] }
    correct_index { 2 }
    explanation { "Paris is the capital of France." }
  end
end
