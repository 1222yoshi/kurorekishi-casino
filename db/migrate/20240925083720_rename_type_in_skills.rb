class RenameTypeInSkills < ActiveRecord::Migration[7.2]
  def change
    rename_column :skills, :type, :skill_type
  end
end
