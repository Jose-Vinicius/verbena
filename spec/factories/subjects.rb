FactoryBot.define do
  factory :subject do
    name { "MyString" }
    association :user
  end
end
