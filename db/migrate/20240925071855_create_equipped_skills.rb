class CreateEquippedSkills < ActiveRecord::Migration[7.2]
  def change
    create_table :equipped_skills do |t|
      t.references :user, foreign_key: true
      t.references :skill, foreign_key: true

      t.timestamps
    end
  end
end
