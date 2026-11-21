require 'rails_helper'

RSpec.describe Sources::SelectChunksService do
  let(:user) { create(:user) }
  let(:subject_record) { create(:subject, user: user) }
  let(:biology_source) { create(:study_source, user: user, subject: subject_record, status: :ready) }
  let(:botany_source) { create(:study_source, user: user, subject: subject_record, status: :ready) }

  before do
    create(:source_chunk, study_source: biology_source, position: 0, content: 'A mitocôndria realiza a respiração celular aeróbica e produz ATP.', char_count: 66, used_count: 0)
    create(:source_chunk, study_source: biology_source, position: 1, content: 'O complexo de Golgi empacota proteínas.', char_count: 39, used_count: 2)
    create(:source_chunk, study_source: botany_source, position: 0, content: 'A fotossíntese ocorre nos cloroplastos das células vegetais.', char_count: 60, used_count: 0)
  end

  it 'uses stratified sampling across sources when no focus_query is given and increments used_count' do
    selected = described_class.call(study_source_ids: [ biology_source.id, botany_source.id ], target_char_budget: 200)

    expect(selected.size).to eq(3)
    expect(selected.first.reload.used_count).to eq(1)
  end

  it 'prioritizes matching chunks via full-text search when focus_query is provided' do
    selected = described_class.call(study_source_ids: [ biology_source.id, botany_source.id ], focus_query: 'mitocôndria ATP', target_char_budget: 80)

    expect(selected.map(&:content)).to include('A mitocôndria realiza a respiração celular aeróbica e produz ATP.')
  end
end
