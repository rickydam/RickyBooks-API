class NotifyItem < ApplicationRecord
  belongs_to :user

  validates_presence_of :category, :input
end
