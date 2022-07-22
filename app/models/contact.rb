class Contact < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search_scope,
    against: [:name, :phone_number],
    using: { tsearch: { prefix: true } }

  scope :search, ->(value) { search_scope(value) if value.present? }
end
