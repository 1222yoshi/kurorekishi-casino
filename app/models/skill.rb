class Skill < ApplicationRecord
  has_many :bought_skills
  has_many :equipped_skills
end