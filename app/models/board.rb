class Board < ApplicationRecord
  belongs_to :user
  has_many :purchases, dependent: :destroy
  has_many :purchasing_users, through: :purchases, source: :user

  validates :body, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
end