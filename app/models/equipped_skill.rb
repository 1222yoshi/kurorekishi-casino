class EquippedSkill < ApplicationRecord
  belongs_to :user
  belongs_to :skill
end