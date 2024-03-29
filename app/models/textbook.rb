class Textbook < ApplicationRecord
  belongs_to :user
  has_one :conversation, dependent: :destroy
  has_many :images, dependent: :destroy

  validates :textbook_title,      presence: true
  validates :textbook_author,     presence: true
  validates :textbook_edition,    presence: true
  validates :textbook_condition,  presence: true
  validates :textbook_type,       presence: true
  validates :textbook_coursecode, presence: true
  validates :textbook_price,      presence: true
end
