FactoryBot.define do
  factory :study_source do
    user
    subject
    title { "Apostila de Biologia.pdf" }
    source_type { :pdf }
    status { :pending }
    selected { true }
  end
end
