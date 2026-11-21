require 'rails_helper'

RSpec.describe Sources::ChunkTextService do
  let(:user) { create(:user) }
  let(:subject_record) { create(:subject, user: user) }
  let(:study_source) { create(:study_source, user: user, subject: subject_record, source_type: :pdf) }

  it 'splits long segments into overlapping chunks and persists SourceChunk records' do
    long_paragraph = ("Texto de estudo importante sobre biologia celular. " * 80).strip
    segments = [
      { text: long_paragraph, metadata: { 'page' => 1 } },
      { text: 'Resumo curto da página 2.', metadata: { 'page' => 2 } }
    ]

    stats = described_class.call(study_source, segments)

    expect(stats[:pages_count]).to eq(2)
    expect(stats[:chunks_count]).to be >= 3
    expect(study_source.source_chunks.kept.count).to eq(stats[:chunks_count])
    expect(study_source.source_chunks.kept.first.metadata).to eq({ 'page' => 1 })
    expect(study_source.source_chunks.kept.last.metadata).to eq({ 'page' => 2 })
  end
end
