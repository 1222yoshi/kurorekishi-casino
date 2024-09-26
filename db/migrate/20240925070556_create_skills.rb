class CreateSkills < ActiveRecord::Migration[7.2]
  def change
    create_table :skills do |t|
      t.string :name
      t.string :description
      t.integer :type
      t.integer :price
      
      t.timestamps
    end
  end
end
