class Textbook < ApplicationRecord
  validates :textbook_title,      presence: true
  validates :textbook_author,     presence: true
  validates :textbook_edition,    presence: true
  validates :textbook_condition,  presence: true
  validates :textbook_type,       presence: true
  validates :textbook_coursecode, presence: true
end
