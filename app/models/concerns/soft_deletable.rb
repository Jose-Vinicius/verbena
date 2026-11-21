module SoftDeletable
  extend ActiveSupport::Concern

  included do
    scope :kept, -> { where(deleted_at: nil) }
    scope :deleted, -> { where.not(deleted_at: nil) }
    scope :active, -> { kept } unless respond_to?(:active)
  end

  def soft_delete!(timestamp = Time.current)
    update!(deleted_at: timestamp)
  end

  def deleted?
    deleted_at.present?
  end

  def active?
    deleted_at.nil?
  end
end
