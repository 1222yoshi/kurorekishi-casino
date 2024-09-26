class User < ApplicationRecord
  authenticates_with_sorcery!

  before_validation :set_default_coin, on: :create
  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }
  validates :name, presence: true, uniqueness: true

  has_many :boards
  has_many :purchases
  has_many :purchased_boards, through: :purchases, source: :board
  has_many :bought_skills
  has_many :equipped_skills
  has_many :skills, through: :bought_skills, source: :skill
  has_many :equipped, through: :equipped_skills, source: :skill
  validates :coin, numericality: { greater_than_or_equal_to: 0 }

  private

  def set_default_coin
    self.coin ||= 0
  end
end
