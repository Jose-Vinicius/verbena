class SourceChunk < ApplicationRecord
  include SoftDeletable

  belongs_to :study_source

  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :content, presence: true

  scope :search_full_text, ->(query) {
    where("searchable @@ websearch_to_tsquery('portuguese', ?)", query)
      .select(sanitize_sql_array([ "source_chunks.*, ts_rank(searchable, websearch_to_tsquery('portuguese', ?)) AS search_rank", query ]))
      .order(Arel.sql("search_rank DESC, position ASC"))
  }

  def source_label
    parts = [ study_source.title ]
    parts << "Página #{metadata['page']}" if metadata["page"].present?
    parts << "Slide #{metadata['slide']}" if metadata["slide"].present?
    parts.join(" · ")
  end
end
