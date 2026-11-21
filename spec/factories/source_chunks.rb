FactoryBot.define do
  factory :source_chunk do
    study_source
    position { 0 }
    content { "Conteúdo de exemplo para geração de questões." }
    char_count { content.length }
    used_count { 0 }
    metadata { { "page" => 1 } }
  end
end
